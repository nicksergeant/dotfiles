import { ActionPanel, Action, List, showToast, Toast, Icon } from "@raycast/api";
import { useExec, useCachedState } from "@raycast/utils";
import { useState, useEffect } from "react";
import { basename, dirname } from "path";
import { existsSync, statSync } from "fs";

const CACHE_FILE = "/tmp/raycast_fd_cache";
const CACHE_AGE = 24 * 60 * 60 * 1000;
const HOME = process.env.HOME || "~";
const FD_PATH = "/opt/homebrew/bin/fd";
const FZF_PATH = "/opt/homebrew/bin/fzf";

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
  const imageExtensions = [".jpg", ".jpeg", ".png", ".gif", ".webp", ".bmp", ".svg", ".ico", ".tiff", ".heic"];
  return imageExtensions.some((ext) => filePath.toLowerCase().endsWith(ext));
};

export default function Command() {
  const [searchText, setSearchText] = useState("");
  const [results, setResults] = useState<string[]>([]);
  const [showDetails, setShowDetails] = useCachedState("show-details", true);

  const { isLoading: isCaching } = useExec("sh", ["-c", BUILD_CACHE_CMD], {
    execute: needsCacheRefresh(),
    onError: (error) => {
      showToast({
        style: Toast.Style.Failure,
        title: "Failed to build file cache",
        message: error.message,
      });
    },
  });

  const { data: searchData, isLoading: isSearching } = useExec(
    "sh",
    ["-c", `cat ${CACHE_FILE} | ${FZF_PATH} --filter "${searchText}" | head -10`],
    { execute: searchText.length > 0 && !isCaching },
  );

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
          // File might have been deleted
        }

        const isImage = isImageFile(filePath);
        const markdown = isImage ? `<img src="${encodeURI(filePath)}" />` : undefined;

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
                <Action.CopyToClipboard content={filePath} title="Copy Path" />
                <Action.ToggleQuickLook shortcut={{ modifiers: ["cmd"], key: "y" }} />
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
