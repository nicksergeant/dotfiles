# Author: Nick Sergeant <nick@nicksergeant.com>
# Source: https://github.com/nicksergeant/dotfiles/blob/master/zshrc

# Environment ------------------------------------------ {{{

export CFLAGS=-Qunused-arguments
export CPPFLAGS="-Qunused-arguments"
export EDITOR='nvim'
export GOPATH=$HOME/.go
export GOROOT=/usr/local/opt/go/libexec
export ZSH=~/.oh-my-zsh

export PATH=~/.local/bin:$PATH
export PATH=~/Sources/dotfiles/bin:$PATH
export PATH=$GOPATH/bin:$PATH
export PATH=$GOROOT/bin:$PATH
export PATH=/usr/local/sbin:$PATH
export PATH=/opt/homebrew/bin:$PATH
export PATH=/usr/local/bin:$PATH
export PATH=~/Library/Python/3.8/bin:$PATH

# Ruby
export PATH=/opt/homebrew/lib/ruby/gems/2.7.0/bin:$PATH
export PATH=/opt/homebrew/opt/ruby@2.7/bin:$PATH

export CPPFLAGS="-I/opt/homebrew/opt/ruby@2.7/include -Qunused-arguments"
export LDFLAGS="-L/opt/homebrew/opt/ruby@2.7/lib"
export PKG_CONFIG_PATH="/opt/homebrew/opt/ruby@2.7/lib/pkgconfig"

# }}}
# Oh My Zsh ------------------------------------------ {{{

fpath+=${ZDOTDIR:-~}/.zsh_functions
DISABLE_UNTRACKED_FILES_DIRTY="true"
ZSH_THEME=""
plugins=(git zsh-autosuggestions)
source $ZSH/oh-my-zsh.sh

# }}}
# Aliases ------------------------------------------ {{{

alias brew='/opt/homebrew/bin/brew'
alias ct='ctags --options=$HOME/.ctags .'
alias deact='deactivate'
alias dokku='$HOME/.dokku/contrib/dokku_client.sh'
alias gc='hub compare $(git rev-parse --abbrev-ref HEAD)'
alias glco='get_last_commit'
alias gp='git push -u origin HEAD'
alias ibrew='arch -x86_64 /usr/local/bin/brew'
alias j=z
alias o='open'
alias pm='python manage.py'
alias ta='tmux attach -t'
unalias gd
unalias gpd
unalias gst

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
  tmux new-session -d -s vim -n social
  tmux send-keys j Space Social Enter
  tmux send-keys m Enter
  tmux attach
}

wo() {
  VENV=`cat .venv`
  source ~/.virtualenvs/$VENV/bin/activate
}

# }}}
# Imports ------------------------------------------ {{{

. ~/.hubspot/shellrc
. ~/.zshrc-env
. ~/Sources/dotfiles-private/zshrc
. ~/Sources/z/z.sh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# }}}
