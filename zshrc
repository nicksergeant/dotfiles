# Environment variables

export CFLAGS=-Qunused-arguments
export CPPFLAGS=-Qunused-arguments
export EDITOR='nvim'
export GOPATH=$HOME/.go
export GOROOT=/usr/local/opt/go/libexec
export PATH=$PATH:~/.local/bin
export PATH=$PATH:~/Sources/dotfiles/bin
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:$GOROOT/bin
export PATH=$PATH:/usr/local/sbin
export PATH=$PATH:/opt/homebrew/bin
export PATH=$PATH:/usr/local/bin
export PATH=$PATH:~/Library/Python/3.8/bin
export ZSH=~/.oh-my-zsh

fpath+=${ZDOTDIR:-~}/.zsh_functions

# oh-my-zsh

DISABLE_UNTRACKED_FILES_DIRTY="true"
ZSH_THEME=""
plugins=(git zsh-autosuggestions)
source $ZSH/oh-my-zsh.sh

# z

alias j=z
source ~/Sources/z/z.sh

# Aliases

alias brew='/opt/homebrew/bin/brew'
alias ct='ctags --options=$HOME/.ctags .'
alias deact='deactivate'
alias dokku='$HOME/.dokku/contrib/dokku_client.sh'
alias gc='hub compare $(git rev-parse --abbrev-ref HEAD)'
alias glco='get_last_commit'
alias gp='git push -u origin HEAD'
alias ibrew='arch -x86_64 /usr/local/bin/brew'
alias n='vim ~/Dropbox/Documents/Notes/Notes.md'
alias o='open'
alias pm='python manage.py'
alias ta='tmux attach -t'
unalias gd
unalias gpd
unalias gst

# Prompt

autoload -U promptinit; promptinit
prompt pure

# fzf

if [[ -a /usr/share/fzf/key-bindings.zsh ]]; then
  source /usr/share/fzf/key-bindings.zsh
else
  source /usr/local/opt/fzf/shell/key-bindings.zsh
fi

if [[ -a /usr/share/fzf/completion.zsh ]]; then
  source /usr/share/fzf/completion.zsh
else
  source /usr/local/opt/fzf/shell/completion.zsh
fi

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

# Node

# export NVM_DIR="$HOME/.nvm"
# nvm_load() {
#   . $NVM_DIR/nvm.sh
#   . $NVM_DIR/bash_completion
# }
# alias node='unalias nvm; unalias node; unalias npm; nvm_load; node $@'
# alias npm='unalias nvm; unalias node; unalias npm; nvm_load; npm $@'
# alias nvm='unalias nvm; unalias node; unalias npm; nvm_load; nvm $@'

# Functions

# c - browse chrome history
c() {
  local cols sep
  cols=$(( COLUMNS / 3 ))
  sep='{::}'

  cp -f ~/Library/Application\ Support/Google/Chrome/Default/History /tmp/h

  sqlite3 -separator $sep /tmp/h \
    "select substr(title, 1, $cols), url
     from urls order by last_visit_time desc" |
  awk -F $sep '{printf "%-'$cols's  \x1b[36m%s\x1b[m\n", $1, $2}' |
  fzf --ansi --multi | sed 's#.*\(https*://\)#\1#' | xargs open
}

doge() {
  suchvalue DAYrpmB2mVGZeRdLRmz2Jwf5VccN7t3nRf DAqKq1SG9abegwcpPEcdmYsr4NWfZSZLA6 DT45nQ43qBCGbPS9ud4JXBKAMUMsnq6MuU DFebfjwBLp248Rr4fZ3yXJHg4B25N9Npau
}

gd() {
  git diff HEAD
}

gla() {
  find . -maxdepth 1 -mindepth 1 -type d -exec sh -c '(echo {} && cd {} && git pull && echo)' \;
}

gpd() {
  git push
  make deploy
}

gs() {
  git status -s
}

gsa() {
  find . -maxdepth 1 -mindepth 1 -type d -exec sh -c '(echo {} && cd {} && git status && echo)' \;
}

m() {
  if [ "$@" ] ; then
    nvim $@
  else
    nvim .
  fi
}

npmrc-hs() {
  cp ~/.npmrc-hs ~/.npmrc
}

npmrc-ns() {
  cp ~/.npmrc-ns ~/.npmrc
}

# Temporary reinitializations for USB keyboard and mouse after
# waking from suspend. Need to set this up on a systemd resume config.
resume() {
  xmodmap ~/.Xmodmap
  xset r rate 285 30
  killall xcape
  /usr/bin/xcape
  xrandr --output DP-1 --primary --mode 3840x2160 --pos 0x0 --output eDP-1 --mode 2560x1440 --pos 3840x0
  feh --bg-scale ~/.wallpaper.png
}

tn() {
  tmux new-session -d -s notes -n notes
  tmux attach
}

ts() {
  tmux new-session -d -s shell -n shell
  tmux split-window -t shell -h
  tmux attach
}

tv() {
  tmux new-session -d -s vim -n vim
  tmux attach
}

wo() {
  VENV=`cat .venv`
  source ~/.virtualenvs/$VENV/bin/activate
}

# Import private settings

source ~/Sources/dotfiles-private/zshrc
source ~/.zshrc-env
. ~/.hubspot/shellrc
