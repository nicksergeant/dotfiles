# Fuzzy Find

Blazing fast fuzzy file/folder search for Raycast using `fd` and `fzf`.

## Features

- True fuzzy matching like `fzf` (e.g., "pub v2" → "public/flxwebsites-v2")
- Abbreviation matching (e.g., "nar" → "Notes and Reference")
- Cached file indexing for instant results (24-hour cache)
- File metadata display (size, creation date, modification date)
- Image preview support in detail view
- Quick Look integration (⌘Y)
- Respects common exclusions (node_modules, Library, Pictures, Music)

## Installation

### Prerequisites

Install required dependencies:
```bash
brew install fd fzf
```

### Build and Install

1. Build the extension:
   ```bash
   cd raycast-extensions/fuzzy-find
   npm install
   npm run build
   ```

2. The extension will be automatically available in Raycast after building

### Development Mode

To develop with live reloading:
```bash
npm run dev
```

## Usage

1. Open Raycast (⌘Space)
2. Type "Search Files" or your configured command name
3. Enter your fuzzy search query:
   - `dcalc` → finds "distance calculator.xlsx"
   - `pub v2` → finds "public/flxwebsites-v2"
   - `nar` → finds "Notes and Reference"
   - `img v2` → finds images in "flxwebsites-v2/img"

## Keyboard Shortcuts

- **⌘Y** - Quick Look preview
- **⌘⇧D** - Toggle detail view
- **⌘R** - Refresh cache
- **↵** - Open file/folder
- **⌘↵** - Show in Finder
- **⌘C** - Copy file path

## Cache Management

The extension caches file paths at `/tmp/raycast_fd_cache` for 24 hours.

**Manual refresh:**
- Press **⌘R** within the extension to rebuild the cache immediately

**Terminal refresh:**
```bash
rm /tmp/raycast_fd_cache
```

The cache will automatically rebuild on next use or after 24 hours.

## Configuration

Edit `src/index.tsx` to customize:
- Cache duration (default: 24 hours)
- Search depth (default: 7 levels)
- Excluded directories
- Result limit (default: 10 items)

## Development

```bash
npm run dev      # Start development mode with live reload
npm run build    # Build production version
npm run lint     # Run linter
```

## Dependencies

- **fd** - Fast file finder written in Rust
- **fzf** - Fuzzy finder written in Go
- **@raycast/api** - Raycast extension API
- **@raycast/utils** - Raycast utilities for hooks
