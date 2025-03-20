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
alias o='open'
alias pm='python manage.py'
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

# zle -N fzf-git-branches-widget

export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --no-messages --glob "!.git/*"'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# alias bs="bend-multi"
# bindkey '^G' fzf-file-widget
# bindkey '^J' fzf-cd-widget
# bindkey '^O' fzf-git-branches-widget

# }}}
# Functions ------------------------------------------ {{{

unalias gd

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

gs() {
  if [ -d .git ]
  then
    git status -s
  else
    find . -maxdepth 1 -mindepth 1 -type d -exec sh -c '(echo {} && cd {} && git status -s && echo)' \;
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

# }}}
# Imports ------------------------------------------ {{{

. ~/.env
. ~/Sources/z/z.sh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# }}}

# Added by nex: https://git.hubteam.com/HubSpot/nex
. ~/.hubspot/shellrc
