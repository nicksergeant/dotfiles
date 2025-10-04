# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a custom Raycast extension that provides blazing fast fuzzy file/folder search using `fd` and `fzf`, replicating terminal-style fuzzy matching within Raycast's UI.

## Build Commands

```bash
npm run dev      # Start development mode with live reload
npm run build    # Build production version
npm run lint     # Run linter
```

## Architecture

The extension consists of:

1. **src/search-files-folders.tsx** - Main React component that:
   - Caches fd output to `/tmp/raycast_fd_cache` (24-hour TTL)
   - Uses `useExec` hook to shell out to `fzf --filter` for fuzzy matching
   - Renders results in a `List` component with detail view
   - Shows file metadata (size, dates, type)
   - Displays image previews using HTML `<img>` tags in markdown
   - Limits results to 10 items (`head -10`)

2. **package.json** - Extension manifest that:
   - Defines the "Search Files" command
   - Lists dependencies (@raycast/api, @raycast/utils)
   - Contains build scripts

## Key Implementation Details

### Cache Behavior
- Cache file: `/tmp/raycast_fd_cache`
- Cache age: 24 hours (86400000 ms)
- Auto-refresh: Checks on component mount via `needsCacheRefresh()`
- Manual clear: `rm /tmp/raycast_fd_cache`

### Search Scope
- Starts from current directory and home (~)
- Max depth: 7 levels
- Excludes: Library, Pictures, Music, node_modules

### Binary Paths
- **IMPORTANT**: Must use absolute paths for fd and fzf
- Default: `/opt/homebrew/bin/fd` and `/opt/homebrew/bin/fzf`
- Raycast extensions don't have Homebrew in PATH

### Image Preview
- Images detected by extension (.jpg, .jpeg, .png, .gif, .webp, .bmp, .svg, .ico, .tiff, .heic)
- Displayed using HTML in markdown: `<img src="${encodeURI(filePath)}" style="height: 100%;" />`
- **Must use `encodeURI()` for paths with spaces**
- Raycast markdown does NOT support local file paths in standard markdown syntax (`![](path)`)
- HTML `<img>` tags work for local files

### Action Requirements
- All `Action` components require a `title` prop at runtime (even if TypeScript types mark it optional)
- `Action.ToggleQuickLook` requires `quickLook` prop on parent `List.Item`

### State Management
- `useCachedState` for persistent UI state (showDetails)
- `useState` for search text and results
- `useExec` for shell command execution
- `useEffect` for processing search results

## Testing Changes

1. Run `npm run dev` for live reload during development
2. Extension auto-reloads in Raycast when files change
3. Test search queries with various patterns
4. Test image preview with paths containing spaces
5. Run `npm run build` for production build

## Common Patterns

### Executing Shell Commands
```typescript
const { data, isLoading } = useExec("sh", ["-c", command], {
  execute: shouldExecute,
  onError: (error) => showToast(...)
});
```

### File Path Handling
- Always convert to `~` for display: `filePath.replace(HOME, "~")`
- Use absolute paths for operations: keep original `filePath`
- URL-encode for markdown images: `encodeURI(filePath)`

### List.Item.Detail
- Can combine `markdown` and `metadata` props
- Markdown supports HTML for images
- Metadata uses `List.Item.Detail.Metadata` components

## Dependencies

Required system packages:
- `fd` - Fast file finder written in Rust
- `fzf` - Fuzzy finder written in Go

NPM dependencies:
- `@raycast/api` - Core Raycast API
- `@raycast/utils` - Utility hooks (useExec, useCachedState)
