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
alias love="/Applications/Love.app/Contents/MacOS/love"
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
    --exclude '.*' \
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
    make run
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
  local final_msg=$(echo "$diff" | claude -p "Generate a git commit message for these changes. Be specific about what was changed. Include specific keywords and technical terms (function names, file types, configuration settings, etc.) that would be useful for searching commit history later.

CRITICAL: The FIRST LINE must be NO MORE THAN 72 CHARACTERS to fit GitHub PR titles. This is mandatory.

If the changes are substantial or involve multiple related modifications, use bullet points to organize the details. For simple changes, a single sentence is fine. For complex changes with multiple aspects, use a format like:
Main change description (max 72 chars).

- First detail
- Second detail
- Third detail

IMPORTANT: Focus on the PURPOSE and IMPACT of changes. Explain WHY the change was needed based on what you can infer from the diff:
- What problem does this solve?
- What capability does this add?
- What improvement does this make?
- What issue or limitation does this address?

DO NOT mention:
- Basic imports or hook usage (e.g., 'Imported useEffect', 'Added useState')
- Standard code structure changes that are obvious from the diff
- Trivial refactoring details that don't affect functionality
- Implementation details that are self-evident from reading the code
- Redundant file/component names (e.g., 'Updated Button in FileButton.tsx' - just describe WHAT changed)

DO mention:
- New features or capabilities added
- Bug fixes and what issue they resolve
- Performance improvements and their impact
- Changes to business logic or algorithms
- API changes or new integrations
- Security improvements
- User-facing changes

Focus on WHAT changed and WHY it matters, not WHERE it changed (the diff already shows that). For example:
- BAD: 'Updated Button component in FileButton.tsx'
- GOOD: 'Fixed button inline margin from new marginInline prop'
- BAD: 'Modified UserProfile component'
- GOOD: 'Added email validation to user profile form'

Use proper sentences with correct capitalization and punctuation, including periods at the end of sentences. Do not include any co-authorship or attribution to Claude/AI in the commit message. Return only the commit message without any explanation or formatting. Remember: FIRST LINE MUST BE ≤72 CHARACTERS." --output-format text | edit_pipe)
  
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
