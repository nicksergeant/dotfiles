import { ActionPanel, Action, List, showToast, Toast, Icon } from "@raycast/api";
import { useExec, useCachedState } from "@raycast/utils";
import { useState, useEffect } from "react";
import { basename, dirname } from "path";
import { existsSync, statSync, unlinkSync } from "fs";

const CACHE_FILE = "/tmp/raycast_fd_cache";
const CACHE_AGE = 24 * 60 * 60 * 1000;
const HOME = process.env.HOME || "~";
const FD_PATH = "/opt/homebrew/bin/fd";
const FZF_PATH = "/opt/homebrew/bin/fzf";
const IMAGE_EXTENSIONS = [".jpg", ".jpeg", ".png", ".gif", ".webp", ".bmp", ".svg", ".ico", ".tiff", ".heic"];

const BUILD_CACHE_CMD = `(echo "$PWD"; ${FD_PATH} . ${HOME} --max-depth 7 \
  --exclude Library \
  --exclude Pictures \
  --exclude Music \
  --exclude node_modules \
  2>/dev/null) > ${CACHE_FILE}`;

const needsCacheRefresh = () => {
  if (!existsSync(CACHE_FILE)) return true;
  const age = Date.now() - statSync(CACHE_FILE).mtimeMs;
  return age > CACHE_AGE;
};

const formatFileSize = (bytes: number): string => {
  if (bytes === 0) return "0 B";
  const k = 1024;
  const sizes = ["B", "KB", "MB", "GB"];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return `${(bytes / Math.pow(k, i)).toFixed(1)} ${sizes[i]}`;
};

const formatDate = (date: Date): string => {
  return date.toLocaleString("en-US", {
    year: "numeric",
    month: "short",
    day: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
};

const isImageFile = (filePath: string): boolean => {
  return IMAGE_EXTENSIONS.some((ext) => filePath.toLowerCase().endsWith(ext));
};

export default function Command() {
  const [searchText, setSearchText] = useState("");
  const [results, setResults] = useState<string[]>([]);
  const [showDetails, setShowDetails] = useCachedState("show-details", true);
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [searchKey, setSearchKey] = useState(0);

  const { isLoading: isCaching, revalidate: revalidateCache } = useExec("sh", ["-c", BUILD_CACHE_CMD], {
    execute: needsCacheRefresh(),
    onError: (error) => {
      showToast({
        style: Toast.Style.Failure,
        title: "Failed to build file cache",
        message: error.message,
      });
      setIsRefreshing(false);
    },
  });

  const { data: searchData, isLoading: isSearching } = useExec(
    "sh",
    ["-c", `cat ${CACHE_FILE} | ${FZF_PATH} --filter "${searchText}" | head -10 # ${searchKey}`],
    {
      execute: searchText.length > 0 && !isCaching,
    },
  );

  const handleRefreshCache = () => {
    try {
      if (existsSync(CACHE_FILE)) {
        unlinkSync(CACHE_FILE);
      }
      setResults([]);
      setIsRefreshing(true);
      showToast({
        style: Toast.Style.Animated,
        title: "Rebuilding cache...",
      });
      revalidateCache();
    } catch (error) {
      showToast({
        style: Toast.Style.Failure,
        title: "Failed to refresh cache",
        message: error instanceof Error ? error.message : "Unknown error",
      });
      setIsRefreshing(false);
    }
  };

  useEffect(() => {
    if (isRefreshing && !isCaching) {
      showToast({
        style: Toast.Style.Success,
        title: "Cache refreshed",
      });
      setIsRefreshing(false);
      if (searchText.length > 0) {
        setSearchKey((prev) => prev + 1);
      }
    }
  }, [isCaching, isRefreshing]);

  useEffect(() => {
    if (searchData && searchText) {
      const paths = searchData.split("\n").filter((path) => path.trim() && path.includes("/"));
      setResults(paths);
    } else {
      setResults([]);
    }
  }, [searchData, searchText]);

  return (
    <List
      isLoading={isCaching || isSearching}
      isShowingDetail={showDetails}
      filtering={false}
      onSearchTextChange={setSearchText}
      searchBarPlaceholder="Search files..."
      throttle
    >
      {results.map((filePath) => {
        const displayPath = filePath.replace(HOME, "~");
        const name = basename(filePath);

        let stats;
        let fileType = "Unknown";
        try {
          stats = statSync(filePath);
          fileType = stats.isDirectory() ? "Folder" : "File";
        } catch {
          // Deleted file
        }

        const isImage = isImageFile(filePath);
        const markdown = isImage ? `<img src="${encodeURI(filePath)}" style="height: 100%;" />` : undefined;

        return (
          <List.Item
            key={filePath}
            icon={{ fileIcon: filePath }}
            title={name}
            subtitle={!showDetails ? dirname(displayPath) : undefined}
            quickLook={{ path: filePath }}
            detail={
              <List.Item.Detail
                markdown={markdown}
                metadata={
                  <List.Item.Detail.Metadata>
                    <List.Item.Detail.Metadata.Label title="Name" text={name} />
                    <List.Item.Detail.Metadata.Label title="Where" text={dirname(displayPath)} />
                    <List.Item.Detail.Metadata.Separator />
                    <List.Item.Detail.Metadata.Label title="Type" text={fileType} />
                    {stats && !stats.isDirectory() && (
                      <List.Item.Detail.Metadata.Label title="Size" text={formatFileSize(stats.size)} />
                    )}
                    {stats && (
                      <>
                        <List.Item.Detail.Metadata.Label title="Created" text={formatDate(stats.birthtime)} />
                        <List.Item.Detail.Metadata.Label title="Modified" text={formatDate(stats.mtime)} />
                      </>
                    )}
                  </List.Item.Detail.Metadata>
                }
              />
            }
            actions={
              <ActionPanel>
                <Action.Open target={filePath} title="Open" />
                <Action.ShowInFinder path={filePath} />
                <Action.CopyToClipboard
                  content={filePath}
                  title="Copy Path"
                  shortcut={{ modifiers: ["cmd"], key: "c" }}
                />
                <Action.ToggleQuickLook shortcut={{ modifiers: ["cmd"], key: "y" }} />
                <Action
                  title="Refresh Cache"
                  icon={Icon.ArrowClockwise}
                  shortcut={{ modifiers: ["cmd"], key: "r" }}
                  onAction={handleRefreshCache}
                />
                <Action
                  title={showDetails ? "Hide Details" : "Show Details"}
                  icon={Icon.AppWindowSidebarLeft}
                  shortcut={{ modifiers: ["cmd", "shift"], key: "d" }}
                  onAction={() => setShowDetails(!showDetails)}
                />
              </ActionPanel>
            }
          />
        );
      })}
    </List>
  );
}
