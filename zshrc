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
export PATH="/Applications/Alacritty Shell.app/Contents/MacOS:$PATH"
export PATH="/usr/local/bin:$PATH"
export PATH="/Applications/Love.app/Contents/MacOS:$PATH"

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
alias i='make shell'
alias ibrew='arch -x86_64 /usr/local/bin/brew'
alias j=z
alias o='open'
alias pm='python manage.py'
alias s='supabase'
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
  selected_item=$( (echo "$PWD"; fd . ~ --type f --type d --max-depth 6 \
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

n() {
  _z not
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
  if [ -d .git ]
  then
    BRANCH=$(git branch --show-current)
    git fetch origin $BRANCH && git rebase origin/$BRANCH
  else
    find . -maxdepth 1 -mindepth 1 -type d ! -name '.claude' -exec sh -c '(echo {} && cd {} && BRANCH=$(git branch --show-current) && git fetch origin $BRANCH && git rebase origin/$BRANCH && echo)' \;
  fi
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
  tmux new-session -d -s shell -n shell
  tmux send-keys -t shell C-l
  tmux split-window -t shell -h
  tmux send-keys -t shell C-l
  tmux new-window -n servers
  tmux send-keys -t servers C-l
  tmux split-window -t servers -h
  tmux send-keys -t servers C-l
  tmux next-window
  tmux attach
}

tv() {
  tmux new-session -d -s vim -n settings-ui
  tmux send-keys j Space settings-ui Enter
  tmux send-keys m Enter
  tmux attach
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
  local final_msg=$(echo "$diff" | claude -p "Write a git commit message for ONLY these staged changes (not the entire branch).

First line: ≤72 chars (for GitHub PR titles)
Body: Use dashes (-) for bullet points (GitHub requirement)

Focus on WHAT changed (facts from the diff):
- Feature additions, bug fixes, API changes
- Performance/security improvements
- Business logic or algorithm changes

Skip obvious things like imports, basic refactoring, or speculation about intent.
Use only dashes (-) for bullet points, never other symbols.

Return only the commit message, no explanations." --output-format text | edit_pipe)
  
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
