# CLAUDE.md - Dotfiles Repository

This file provides guidance to Claude Code (claude.ai/code) when working with this dotfiles repository.

## Repository Purpose

This is a personal dotfiles repository for Nick Sergeant containing:
- Neovim (nvim) configuration with LSP setup, treesitter, and custom plugins
- Zsh shell configuration with custom functions and aliases
- Tmux configuration with vim keybindings
- Git, Alacritty, Karabiner, and ctags configuration
- Raycast extension for fuzzy file search (TypeScript/React)
- Scripts for various utilities
- VS Code (Cursor) settings and keybindings
- Alfred and Firefox addon configurations

License: MIT

## Directory Structure

```
dotfiles/
├── nvim/                          # Neovim configuration
│   ├── init.vim                   # Main vim config (vim script + lua)
│   └── lua/
│       ├── lsp.lua               # LSP configuration (HubSpot-aware)
│       ├── bend.lua              # Bend monorepo integration (HubSpot only)
│       └── bend-filetypes.lua    # Bend supported file types
├── bin/                           # Executable scripts
│   ├── get-chromium-page-title-and-url.scpt  # AppleScript
│   ├── get-last-commit           # Zsh - opens last commit in GitHub
│   ├── nshift                     # macOS brightness control binary
│   └── upload-screenshot         # S3 screenshot uploader
├── scripts/                       # Various utility scripts
│   ├── package.json              # Dependencies for scripts (open, date-fns, prettier)
│   ├── add-things-item-from-linear.ts
│   ├── add-todo.js
│   ├── clean-1password.js
│   ├── copy-chrome-url-and-title.js
│   └── copy-fantastical-calendar-day.js
├── raycast-extensions/
│   └── fuzzy-find/               # Custom Raycast extension
│       ├── CLAUDE.md             # Detailed extension documentation
│       ├── package.json          # Raycast extension manifest
│       ├── src/index.tsx         # Main React component
│       └── tsconfig.json
├── alfred-workflows/             # Alfred workflows (mirrored from raycast)
├── vscode/
│   ├── settings.json             # Linked to Cursor settings
│   ├── keybindings.json          # Linked to Cursor keybindings
│   └── extensions/               # VS Code extensions config
├── zshrc                          # Shell configuration (extensive)
├── tmux.conf                      # Tmux configuration with plugins
├── gitconfig                      # Git aliases and configuration
├── gitignore                      # Global .gitignore
├── alacritty.toml                 # Alacritty terminal config
├── ctags.ctags                    # Ctags configuration
├── karabiner.edn                  # Karabiner config (source)
├── karabiner.json                 # Karabiner config (compiled)
├── link                           # Setup script (bash) to create all symlinks
└── .claude/
    └── settings.local.json        # Claude Code local settings
```

## Key Configuration Systems

### Neovim Setup
- **Plugin manager**: vim-plug
- **Netrw disabled** for nvim-tree
- **LSP**: Uses `vim.lsp.config()` and `vim.lsp.enable()` API (newer pattern)
- **Completion**: nvim-cmp with lspconfig sources
- **Treesitter**: Installed for syntax highlighting and context-aware commenting
- **Linters/Fixers**: ALE with per-language configuration (prettier, eslint, black, rustfmt, stylua, etc.)

**LSP Configuration Details**:
- Checks for `/Users/nsergeant/.isHubspotMachine` file at startup
- If HubSpot machine: Integrates with Bend monorepo system (custom tsserver path)
- If not: Standard typescript-language-server configuration
- Language servers enabled: typescript, graphql, tailwindcss, yamlls, elixirls, emmet
- Keymap shortcuts: `ga` (code action), `gi` (hover), `go` (definition), `gr` (references), `mv` (rename)

**Bend Integration** (HubSpot-specific):
- Custom Lua module in `bend.lua` manages Bend process lifecycle
- Auto-starts Bend on nvim open if `.isHubspotMachine` exists
- Looks for `static_conf.json` files to determine project roots
- Uses `bpx` command to get HubSpot-specific TypeScript server path
- Filters TypeScript diagnostics to hide unrelated warnings (code 7016)

### Zsh Shell

**Key Features**:
- Oh My Zsh with pure prompt
- FZF integration with custom git branch widget
- Custom functions for project management (f, fr, fj, on, onj, onr, m, r, c, n, etc.)
- Machine-specific tmux session setup (HubSpot vs. non-HubSpot)
- Editor pipe functionality (edit_pipe) for stream editing

**AI Integration**:
- `gcam` function uses Claude API (Haiku model) to generate commit messages
- Generates diff-aware commits with human-readable messages
- Prevents AI markers in commit text (enforces human-like output)
- Supports manual editing of generated message via nvim

**Environment**:
- Python via pyenv
- Homebrew paths for ARM and Intel architectures
- Custom PATH entries for dotfiles/bin, meteor, Go, etc.
- PYENV_ROOT initialization

**Notable Aliases**:
- `vim` -> `nvim`
- `c` -> `cursor` (Cursor editor)
- `m` -> `nvim` (Neovim)
- `r` -> `make run`
- `f` -> fuzzy find current project
- `gl` -> git fetch + rebase (works on single or multiple repos)
- `gs` -> git status (handles monorepos)

### Git Configuration
- Custom aliases: `co` (checkout), `pushf` (push --force-with-lease), `merge` (no-ff)
- Pull strategy: rebase
- Default branch: main
- Git LFS enabled
- Custom hooks path: `/Users/nsergeant/.git_hooks`

### Tmux Configuration
- Prefix: `Ctrl+f` (not default Ctrl+b)
- Vim keybindings in copy mode
- Status line shows current session, battery, and time
- Color scheme: Dark theme with 256 colors
- Mouse support enabled
- History limit: 100,000 lines
- Plugins: tpm (tmux plugin manager)

**Custom Bindings**:
- `h/j/k/l` - Navigate panes
- `v` - Split vertically, `s` - Split horizontally
- `o` - Maximize pane
- `g` - Jump to last window
- `r` - Reload config

### Terminal Setup
- Terminal: Alacritty with extensive key bindings
- Custom keyboard bindings for Home/End/PageUp/PageDown
- Supports wide range of applications for opening files

## Development Commands

### Raycast Fuzzy Find Extension
```bash
cd raycast-extensions/fuzzy-find
npm run dev      # Development mode with live reload
npm run build    # Production build
npm run lint     # Linting
```

**Important Implementation Notes**:
- Cache file at `/tmp/raycast_fd_cache` (24-hour TTL)
- Uses absolute paths to `/opt/homebrew/bin/fd` and `/opt/homebrew/bin/fzf` (not in Raycast PATH)
- Image previews use HTML `<img>` tags with URL encoding
- Cmd+R refreshes cache manually
- Search limited to 10 results, searches from current directory and home, max depth 7

### Scripts
```bash
cd scripts
npm install    # Install dependencies
# Individual scripts are mostly JS/TS utilities for macOS automation
```

## Setup and Linking

**Main setup script**: `link` (bash script in root)

What it does:
- Creates required config directories
- Symlinks nvim directory (not just file)
- Symlinks config files to various locations:
  - Neovim: `~/.config/nvim`
  - Alacritty: `~/.config/alacritty/alacritty.toml`
  - Ctags: `~/.config/ctags/ctags.ctags`
  - Karabiner: `~/.config/karabiner/karabiner.json`
  - Git: `~/.gitconfig`, `~/.gitignore`
  - Tmux: `~/.tmux.conf`
  - Zsh: `~/.zshrc`
  - Cursor (VSCode): Linked to `~/Library/Application Support/Cursor/User/`

Run with: `bash /Users/nsergeant/Sources/dotfiles/link` or `./link`

## Important Architectural Notes

### Machine Detection Pattern
The dotfiles use a "machine marker" pattern:
- Presence of `~/.isHubspotMachine` file determines HubSpot-specific behavior
- Affects: LSP configuration, Bend integration, tmux session layouts
- Multiple zsh functions have conditional branches based on this

### Neovim LSP vs. Bend
- **Standard setup** (non-HubSpot): Direct typescript-language-server with root markers
- **HubSpot setup**: Bend process manages multiple TypeScript servers per static_conf.json
- Bend integration uses `vim.loop` (libuv) and `plenary.nvim.Job` for process management

### Absolute Path Dependencies
Several tools rely on absolute paths not in normal PATH:
- Raycast extension uses `/opt/homebrew/bin/fd` and `/opt/homebrew/bin/fzf`
- Karabiner binary at `/Users/nsergeant/Sources/dotfiles/bin/nshift`
- Screenshot uploader uses `/opt/homebrew/bin/aws`

### Custom Vim Plugin
- Uses personal fork of `badwolf` colorscheme
- Custom fork of `goyo.vim` (distraction-free mode)

## Dependencies and Requirements

### System Tools
- `fd` - Fast file finder (Rust)
- `fzf` - Fuzzy finder (Go)
- `rg` - Ripgrep (Rust) - used in zsh FZF_DEFAULT_COMMAND
- `nvim` - Neovim
- `tmux` - Terminal multiplexer
- `ctags` - ctags implementation
- `git` - Git with LFS support
- `aws` CLI - For screenshot uploading
- Node.js - For Raycast extension and scripts

### Language Servers (optional based on usage)
- typescript-language-server
- graphql-language-server
- tailwindcss-language-server
- yaml-language-server
- elixir-ls
- emmet-ls

### Neovim Plugins (managed by vim-plug)
See `nvim/init.vim` lines 148-181 for full list. Key ones:
- LSP: neovim/nvim-lspconfig, hrsh7th/nvim-cmp, onsails/lspkind-nvim
- UI: preservim/nerdtree, junegunn/fzf.vim
- Editing: tpope/vim-surround, tpope/vim-repeat, JoosepAlviste/nvim-ts-context-commentstring
- AI: github/copilot.vim
- Linting: dense-analysis/ale
- Treesitter: nvim-treesitter/nvim-treesitter

## Maintenance Notes

### Recent Changes (from git log)
- Oct 18: Fixed TypeScript LSP root_markers configuration (vim.lsp.config API)
- Oct 4: Raycast fuzzy-find extension improvements (cache refresh, image preview)
- Sep 25: Updated zshrc
- Mar 15: Multiple configuration updates and standardization

### Known Idiosyncrasies
- Right command key is remapped to left command in Karabiner
- Caps lock acts as escape when tapped, control when held
- Git merge requires --no-ff flag by default
- Cursor (not VS Code) is the primary editor, with linked settings

### CloudFlare Workers Pattern
References to `make shell` and `make js` suggest project-specific Makefiles in actual work directories

## Common Development Patterns

### Project-specific Setup
```bash
# Activate project virtualenv
wo    # Activates ~/.virtualenvs/flex/bin/activate

# Open projects quickly
f     # Jump to "fl" (flex) project and open in vim
on    # Jump to "on" project and open in vim
fr    # Jump to flex and run `make run`
onr   # Jump to on and run `make run`
```

### Multi-repo Operations
Functions like `gd`, `gl`, `gs` automatically work on monorepos when called from parent directory, finding all subdirectories and running git commands across them.

### Commit Message Generation
The `gcam` function provides AI-powered commit messages:
- Stages all changes
- Gets diff
- Calls Claude Haiku API with detailed instructions
- Opens generated message in nvim for editing
- Commits with final message

## Important Guidelines for Claude Code

### Commit Messages
**Never attribute Claude or any other AI tooling in commit messages.** Write commits as if the changes were authored by you directly. Commit messages should reflect the actual changes made without mentioning AI assistance or Claude Code.

## File Modification Status

Check current state:
```bash
git status
git diff
```

This repository has a modified file: `bin/get-chromium-page-title-and-url.scpt`
