# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a custom Alfred workflow that provides blazing fast fuzzy file/folder search using `fd` and `fzf`, replicating terminal-style fuzzy matching within Alfred's UI.

## Build Commands

```bash
make build   # Package the workflow into fuzzy-find.alfredworkflow
make install # Build and install the workflow (opens in Alfred)
make clean   # Remove build artifacts
```

## Architecture

The workflow consists of:

1. **search.sh** - Main search logic that:
   - Caches fd output to `/tmp/alfred_fd_cache` (24-hour TTL)
   - Stores last query in `/tmp/alfred_fd_last_query` for refresh functionality
   - Uses `fzf --filter` for non-interactive fuzzy matching
   - Returns Alfred JSON format with file icons based on type
   - Limits results to 10 items (`head -10`)

2. **info.plist** - Alfred workflow configuration that:
   - Defines the "f" keyword trigger
   - Sets up a hotkey trigger for cache refresh
   - Contains a refresh script that clears cache and re-runs last query

3. **icon.png** - Custom workflow icon

## Key Implementation Details

### Cache Behavior
- Cache file: `/tmp/alfred_fd_cache` 
- Cache age: 86400 seconds (24 hours)
- Manual refresh via hotkey clears cache and re-runs last query

### Search Scope
- Starts from current directory and home (~)
- Max depth: 6 levels
- Excludes: Library, Pictures, Music, node_modules, dotfiles

### Icon Handling
- Directories: Use `fileicon` type for standard folder icons
- Images (.jpg, .png, .webp, etc.): Use `filepath` type for actual previews
- Other files: Use `fileicon` type for file type icons

## Testing Changes

After modifying any file, always run `make install` to rebuild and reinstall the workflow in Alfred. This is required for changes to take effect.

1. Run `make install` (builds and installs automatically)
2. Test with `f <query>` in Alfred
3. Test cache refresh with configured hotkey

## Dependencies

Required Homebrew packages:
- `fd` - Fast file finder written in Rust
- `fzf` - Fuzzy finder written in Go