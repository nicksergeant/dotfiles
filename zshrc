# Author: Nick Sergeant <nick@nicksergeant.com>
# Source: https://github.com/nicksergeant/dotfiles/blob/master/zshrc

# Environment ------------------------------------------ {{{

export CFLAGS=-Qunused-arguments
export CPPFLAGS="-Qunused-arguments"
export EDITOR='nvim'
export ZSH=~/.oh-my-zsh

export PATH="/Users/nsergeant/.meteor":$PATH
export PATH="/Users/nsergeant/go/bin":$PATH
export PATH="/Users/nsergeant/Sources/dotfiles/bin:$PATH"
export PATH="/Users/nsergeant/Library/Python/3.8/bin:$PATH"
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"
export PATH="/Applications/Alacritty Shell.app/Contents/MacOS:$PATH"
export PATH="/usr/local/bin:$PATH"
export PATH="/Applications/Love.app/Contents/MacOS:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

if [ "$(uname -p)" = "arm" ]
then
  export PATH="/opt/homebrew/bin:$PATH"
fi

# }}}
# Oh My Zsh ------------------------------------------ {{{

fpath+=${ZDOTDIR:-~}/.zsh_functions
fpath+=$HOME/.zsh/pure
DISABLE_UNTRACKED_FILES_DIRTY="true"
DISABLE_AUTO_UPDATE="true"
ZSH_THEME=""
plugins=(git zsh-autosuggestions)
source $ZSH/oh-my-zsh.sh

# }}}
# Aliases ------------------------------------------ {{{

alias brew="$(brew --prefix)/bin/brew"
alias deact='deactivate'
alias gc='hub compare $(git rev-parse --abbrev-ref HEAD)'
alias gdo='git --no-pager diff HEAD'
alias glco='get-last-commit'
alias gp='git push -u origin HEAD'
alias h='ssh nick@home'
alias i='make shell'
alias ibrew='arch -x86_64 /usr/local/bin/brew'
alias j=z
alias npm='pnpm'
alias npx='pnpm'
alias o='open'
alias p='pnpm'
alias pm='python manage.py'
alias s='pnpm supabase'
alias ta='tmux attach -t'
alias vim='nvim'

# }}}
# Prompt ------------------------------------------ {{{

autoload -U promptinit; promptinit
export PURE_CMD_MAX_EXEC_TIME=999999
prompt pure

# }}}
# Fzf ------------------------------------------ {{{

fzf-git-branches-widget() {
  local branches branch
  branches=$(git for-each-ref --count=500 --sort=-committerdate refs/heads/ --format="%(refname:short)") &&
  branch=$(echo "$branches" | fzf -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

bend-multi() {
  local packages selected_packages
  packages=$(find ~/Code -type f -maxdepth 3 -name 'webpack.config.js' ! -path '*/node_modules/*' | sed -E 's|/[^/]+$||' | sort | uniq) &&
  selected_packages=$(echo "$packages" | fzf -m --query "$1") &&
  bend reactor serve $(echo $selected_packages[@]) --update
}

fzf-open-with-app-widget() {
  local selected_item app_choice apps
  
  # Use fd for fast file finding with built-in filtering
  # Start with current directory, then add all other results
  selected_item=$( (echo "$PWD"; fd . ~ --type f --type d --max-depth 7 \
    --exclude Library \
    --exclude Pictures \
    --exclude Music \
    --exclude node_modules \
    2>/dev/null) | \
    fzf --prompt="Select file/folder: " --height=40% --reverse)
  
  # Exit if no selection
  if [ -z "$selected_item" ]; then
    zle reset-prompt
    return 0
  fi
  
  # Curated list of applications
  # Add "cd to directory" as first option
  apps="📁 cd to directory
Pixelmator Pro
Finder
TextEdit
Chromium
HandBrake
Numbers
Preview
Raycast"
  
  # Let user choose an application
  app_choice=$(echo "$apps" | fzf --prompt="Choose action: " --height=40% --reverse)
  
  # Exit if no app selected
  if [ -z "$app_choice" ]; then
    zle reset-prompt
    return 0
  fi
  
  # Handle cd to directory option
  if [[ "$app_choice" == "📁 cd to directory" ]]; then
    if [[ -d "$selected_item" ]]; then
      BUFFER="cd ${(q)selected_item}"
    else
      # If it's a file, cd to its parent directory
      BUFFER="cd ${(q)$(dirname "$selected_item")}"
    fi
    zle accept-line
  else
    # Open the selected item with the chosen application
    if [[ -d "/Applications/${app_choice}.app" ]]; then
      open -a "${app_choice}" "$selected_item"
    else
      # Try opening with the cask name directly
      open -a "${app_choice}" "$selected_item" 2>/dev/null || echo "Could not open with ${app_choice}"
    fi
    zle reset-prompt
  fi
}

zle -N fzf-open-with-app-widget

export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --no-messages --glob "!.git/*"'

# alias bs="bend-multi"
bindkey '^G' fzf-open-with-app-widget

# }}}
# Functions ------------------------------------------ {{{

unalias gd
unalias gl
unalias gcam

c() {
  if [ "$@" ] ; then
    cursor $@
  else
    cursor .
  fi
}

f() {
  _z fl
  wo
  clear
}

fj() {
  f
  make js
}

fr() {
  f
  make run
}

on() {
  _z on
  wo
  clear
}

onj() {
  on
  make js
}

onr() {
  on
  make run
}

gd() {
  if [ -d .git ]
  then
    git diff HEAD
  else
    find . -maxdepth 1 -mindepth 1 -type d -exec sh -c '(echo {} && cd {} && git diff HEAD --color | cat && echo)' \;
  fi
}

gl() {
  ~/Sources/dotfiles/scripts/update-repos.zsh
}

gs() {
  if [ -d .git ]
  then
    git status -s
  else
    find . -maxdepth 1 -mindepth 1 -type d ! -name '.claude' -exec sh -c '(echo {} && cd {} && echo "Branch: $(git branch --show-current)" && git status -s && echo)' \;
  fi
}

m() {
  if [ "$@" ] ; then
    nvim $@
  else
    nvim .
  fi
}

r() {
  if [ -e Makefile ]
  then
    make run "$@"
  else
    bend reactor serve --update
  fi
}

tn() {
  tmux new-session -d -s notes -n notes
  tmux send-keys j Space Notes Enter
  tmux send-keys m Enter
  tmux attach
}

ts() {
  if [ -f ~/.isHubspotMachine ]; then
    # HubSpot machine setup
    # Shell window: two panes side by side
    tmux new-session -d -s shell -n shell
    tmux split-window -t shell:shell -h -c ~/src
    tmux send-keys -t shell:shell.0 C-l
    tmux send-keys -t shell:shell.1 C-l

    # Servers window: two panes side by side
    tmux new-window -t shell: -n servers
    tmux split-window -t shell:servers -h -c ~/src
    tmux send-keys -t shell:servers.0 C-l
    tmux send-keys -t shell:servers.1 C-l
  else
    # Non-HubSpot machine setup
    # Shell window: left pane, right side split into flxwebsites/studio
    tmux new-session -d -s shell -n shell
    tmux split-window -t shell:shell -h -c ~/Code/flxwebsites
    tmux split-window -t shell:shell.1 -v -c ~/Code/studio
    tmux send-keys -t shell:shell.0 C-l
    tmux send-keys -t shell:shell.1 C-l
    tmux send-keys -t shell:shell.2 C-l

    # Servers window: left pane, then right split into top/bottom with make run
    tmux new-window -t shell: -n servers
    tmux split-window -t shell:servers -h -c ~/Code/flxwebsites
    tmux send-keys -t shell:servers.1 'make run' Enter
    tmux split-window -t shell:servers.1 -v -c ~/Code/studio
    tmux send-keys -t shell:servers.2 'make run' Enter
    tmux send-keys -t shell:servers.0 C-l
  fi

  tmux select-window -t shell:shell
  tmux attach -t shell
}

tv() {
  if [ -f ~/.isHubspotMachine ]; then
    # HubSpot machine setup
    tmux new-session -d -s vim -n src -c ~/src
    tmux send-keys -t vim:src.0 'nvim .' Enter
    tmux split-window -t vim:src -h -c ~/src
    tmux send-keys -t vim:src.1 'claude' Enter
  else
    # Non-HubSpot machine setup
    tmux new-session -d -s vim -n flxwebsites -c ~/Code/flxwebsites
    tmux send-keys -t vim:flxwebsites.0 'nvim .' Enter
    tmux split-window -t vim:flxwebsites -h -c ~/Code/flxwebsites
    tmux send-keys -t vim:flxwebsites.1 'claude' Enter

    tmux new-window -t vim -n studio -c ~/Code/studio
    tmux send-keys -t vim:studio.0 'nvim .' Enter
    tmux split-window -t vim:studio -h -c ~/Code/studio
    tmux send-keys -t vim:studio.1 'claude' Enter

    tmux select-window -t vim:flxwebsites
  fi

  tmux attach -t vim
}

wo() {
  source ~/.virtualenvs/flex/bin/activate
}

# Simple vipe replacement - edit piped input in an editor
edit_pipe() {
  local tmpfile=$(mktemp)
  trap "rm -f $tmpfile" EXIT
  
  # Read stdin into temp file
  cat > "$tmpfile"
  
  # Open in editor (default to nvim if EDITOR not set)
  ${EDITOR:-nvim} "$tmpfile" < /dev/tty > /dev/tty
  
  # Output the edited content
  cat "$tmpfile"
}

gcam() {
  # Stage all changes
  git add -A
  
  # Get the staged diff
  local diff=$(git diff --cached)
  
  # Check if there are staged changes
  if [ -z "$diff" ]; then
    echo "No changes to commit"
    return 1
  fi
  
  # Generate commit message using Claude and edit it with nvim
  local final_msg=$(echo "$diff" | exec claude --model haiku -p "Write a git commit message for ONLY these staged changes (not the entire branch).

OUTPUT FORMAT - CRITICAL:
- Return ONLY plain text - no markdown, no code blocks, no formatting
- NEVER use triple backticks (\`\`\`) or any markdown code block syntax
- Do NOT wrap the output in any kind of code fence or formatting markers
- Just write the commit message as plain text and nothing else

CRITICAL RULES - NEVER VIOLATE THESE:
- NEVER write 'Generated with Claude', 'AI-generated', or ANY mention of AI/Claude/LLM/automation
- NEVER add emojis or special formatting markers that suggest AI generation
- Write as if YOU are the developer who made these changes
- The message must appear 100% human-written with no hints of AI involvement
- NO code blocks (\`\`\`), NO markdown formatting, PLAIN TEXT ONLY

COMMIT TITLE (first line):
- Write a comprehensive, descriptive title that gives a clear overview of the change
- Aim for clarity over brevity - use the full 150 characters if needed
- Example: 'Refactor authentication flow to support OAuth2 and improve token refresh handling'
- GitHub will wrap long titles nicely, so don't artificially shorten them

COMMIT BODY:
- For simple, focused changes: Often the title alone is sufficient - no body needed
- Do not elaborate unnecessarily on routine or obvious changes
- For complex changes: Add a brief paragraph explaining the 'why' or important context
- ONLY use bullet points (-) when you have:
  * Multiple disconnected changes that need separate explanation
  * A large refactor touching many components
  * Several distinct bug fixes or features in one commit
- Avoid bullet points for routine changes that the title already describes

Focus on WHAT changed and WHY it matters. Skip obvious implementation details.

REMINDER: Return ONLY the plain text commit message. No code blocks, no markdown, no formatting." --output-format text | edit_pipe)
  
  # Check if the message is empty or contains "Execution error"
  if [ -z "$final_msg" ] || [[ "$final_msg" == "Execution error"* ]]; then
    echo "Commit aborted (Claude API failed or returned empty message)"
    # Unstage the changes
    git reset HEAD
    return 1
  fi
  
  # If we have a valid message, commit with it
  git commit -m "$final_msg"
}

# }}}
# Imports ------------------------------------------ {{{

. ~/.env
. ~/Sources/z/z.sh

source <(fzf --zsh)

# }}}

# Added by nex: https://git.hubteam.com/HubSpot/nex
. ~/.hubspot/shellrc
