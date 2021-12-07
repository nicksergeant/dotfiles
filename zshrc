# Author: Nick Sergeant <nick@nicksergeant.com>
# Source: https://github.com/nicksergeant/dotfiles/blob/master/zshrc

# Environment ------------------------------------------ {{{

export CFLAGS=-Qunused-arguments
export CPPFLAGS="-Qunused-arguments"
export EDITOR='nvim'
export GOPATH=$HOME/.go
export GOROOT=/usr/local/opt/go/libexec
export ZSH=~/.oh-my-zsh

export PATH="~/.local/bin:$PATH"
export PATH="~/Sources/dotfiles/bin:$PATH"
export PATH="~/neovim/bin:$PATH"
export PATH="$GOPATH/bin:$PATH"
export PATH="$GOROOT/bin:$PATH"
export PATH="~/Library/Python/3.8/bin:$PATH"
export PATH="/usr/local/sbin:$PATH"
export PATH="/usr/local/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

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

alias brew='/opt/homebrew/bin/brew'
alias deact='deactivate'
alias gc='hub compare $(git rev-parse --abbrev-ref HEAD)'
alias gdo='git --no-pager diff HEAD'
alias glco='get-last-commit'
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

zle -N fzf-git-branches-widget

export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --no-messages --glob "!.git/*"'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

alias bs="bend-multi"
bindkey '^G' fzf-file-widget
bindkey '^J' fzf-cd-widget
bindkey '^O' fzf-git-branches-widget

# }}}
# Functions ------------------------------------------ {{{

unalias gd
unalias gp

build_alacritty() {
  rm -rf ~/Sources/alacritty && \
  rm -rf /Applications/Alacritty.app && \
  rm -rf /Applications/Alacritty\ Notes.app && \
  rm -rf /Applications/Alacritty\ Shell.app && \
  rm -rf /Applications/Alacritty\ Vim.app && \
  cd ~/Sources && \
  git clone git@github.com:alacritty/alacritty.git && \
  cd alacritty && \
  rustup update && \
  rustup target add x86_64-apple-darwin && \
  rustup target add aarch64-apple-darwin && \
  cargo check --target=x86_64-apple-darwin && \
  cargo check --target=aarch64-apple-darwin && \
  make dmg-universal && \
  cp -r target/release/osx/Alacritty.app /Applications/Alacritty.app && \
  codesign --remove-signature /Applications/Alacritty.app && \
  sudo codesign --force --deep --sign - /Applications/Alacritty.app && \
  cp -r /Applications/Alacritty.app /Applications/Alacritty\ Notes.app && \
  cp -r /Applications/Alacritty.app /Applications/Alacritty\ Shell.app && \
  cp -r /Applications/Alacritty.app /Applications/Alacritty\ Vim.app
}

fl() {
  _z fl
  wo
  clear
}

flj() {
  fl
  make js
}

flr() {
  fl
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

gs() {
  if [ -d .git ]
  then
    git status -s
  else
    find . -maxdepth 1 -mindepth 1 -type d -exec sh -c '(echo {} && cd {} && git status -s && echo)' \;
  fi
}

gp() {
  if [[ $0:A:h =~ "/Code/flex" ]];
  then
    BRANCH=$(git rev-parse --abbrev-ref HEAD)

    if [ "$BRANCH" = 'master' ]; then
      make deploy_frontend
      print
      print Pushing and deploying to Heroku...
      print
      git push -u origin HEAD
    else
      git push -u origin HEAD
    fi
  else
    git push -u origin HEAD
  fi
}

m() {
  if [ "$@" ] ; then
    nvim $@
  else
    nvim .
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
  tmux new-session -d -s vim -n onboarding
  tmux send-keys j Space onboarding Enter
  tmux send-keys m Enter
  tmux attach
}

wo() {
  VENV=`cat .venv`
  source ~/.virtualenvs/$VENV/bin/activate
}

# }}}
# Imports ------------------------------------------ {{{

. ~/.env
. ~/Sources/z/z.sh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# }}}
