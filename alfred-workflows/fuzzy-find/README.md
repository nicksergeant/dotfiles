# Fuzzy Find

Blazing fast fuzzy file/folder search for Alfred using `fd` and `fzf`.

## Features

- True fuzzy matching like `fzf` (e.g., "pub v2" → "public/flxwebsites-v2")
- Abbreviation matching (e.g., "nar" → "Notes and Reference")
- Cached file indexing for instant results (60-second cache)
- Respects common exclusions (node_modules, dotfiles, Library, etc.)

## Installation

1. Install dependencies:
   ```bash
   brew install fd fzf
   ```

2. Build and install the workflow:
   ```bash
   cd alfred-workflows/fuzzy-find
   make install
   ```

## Usage

Type `f` followed by your search query:
- `f dcalc` → finds "distance calculator.xlsx"
- `f pub v2` → finds "public/flxwebsites-v2"
- `f nar` → finds "Notes and Reference"

## Development

```bash
make build   # Build the workflow
make install # Build and install
make clean   # Remove build artifacts
```

## Configuration

Edit `search.sh` to customize:
- Cache duration (default: 60 seconds)
- Search depth (default: 6 levels)
- Excluded directories