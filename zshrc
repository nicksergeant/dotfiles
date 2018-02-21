# Environment variables

export CFLAGS=-Qunused-arguments
export CPPFLAGS=-Qunused-arguments
export EDITOR='vim'
export GOPATH=$HOME/.go
export GOROOT=/usr/local/opt/go/libexec
export INFOPATH=/home/linuxbrew/.linuxbrew/share/info:$INFOPATH
export MANPATH=/home/linuxbrew/.linuxbrew/share/man:$MANPATH
export PYENV_ROOT=$HOME/.pyenv
export PATH=$PATH:/home/linuxbrew/.linuxbrew/Homebrew/Library/Homebrew/vendor/portable-ruby/2.0.0-p648/bin
export PATH=$PATH:$PYENV_ROOT/bin
export PATH=$PATH:~/.local/bin
export PATH=$PATH:~/Sources/dotfiles/bin
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:$GOROOT/bin
export PATH=/home/linuxbrew/.linuxbrew/bin:$PATH
export ZSH=~/.oh-my-zsh

# oh-my-zsh

DISABLE_UNTRACKED_FILES_DIRTY="true"
ZSH_THEME=""
plugins=(git zsh-autosuggestions)
source $ZSH/oh-my-zsh.sh

# z

alias j=z
source ~/Sources/z/z.sh

# Aliases

alias gc='hub compare $(git rev-parse --abbrev-ref HEAD)'
alias glco='hub browse -- commit/$(~/Sources/dotfiles/bin/get_last_commit)'
alias n='vim ~/Dropbox/Documents/Notes/Notes.md'
alias ta='tmux attach -t'
unalias gd
unalias gpd

# Prompt

autoload -U promptinit; promptinit
prompt pure

# Python

if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init --no-rehash -)"
fi

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

export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --no-messages --glob "!.git/*"'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

bindkey '^G' fzf-file-widget
bindkey '^J' fzf-cd-widget

# Functions

bu() {
  echo ------------ App Databases ------------
  echo
  budb
  echo 
  echo ------------ Mac Dropbox to Seagate ------------
  echo
  rsync -ahL --progress ~/Dropbox\ \(Personal\)/ /Volumes/Seagate/Dropbox/
  echo 
  echo ------------ Mac Dropbox to Time Machine ------------
  echo
  rsync -ahL --progress ~/Dropbox\ \(Personal\)/ /Volumes/Time\ Machine/Dropbox/
  echo 
  echo ------------ Mac Photo Booth Library to Seagate ------------
  echo
  rsync -ahL --progress ~/Pictures/Photo\ Booth\ Library/ /Volumes/Seagate/Photo\ Booth\ Library/
  echo
  echo ------------ Mac Photo Booth Library to Time Machine ------------
  echo
  rsync -ahL --progress ~/Pictures/Photo\ Booth\ Library/ /Volumes/Time\ Machine/Photo\ Booth\ Library/
  echo 
  echo ------------ Mac Photos Library to Seagate ------------
  echo
  rsync -ahL --progress ~/Pictures/Photos\ Library.photoslibrary/ /Volumes/Seagate/Photos\ Library.photoslibrary/
  echo
  echo ------------ Mac Photos Library to Time Machine ------------
  echo
  rsync -ahL --progress ~/Pictures/Photos\ Library.photoslibrary/ /Volumes/Time\ Machine/Photos\ Library.photoslibrary/
  echo 
  echo ------------ Seagate Photo Booth Photos to Time Machine ------------
  echo
  rsync -ahL --progress /Volumes/Seagate/Photo\ Booth\ Photos/ /Volumes/Time\ Machine/Photo\ Booth\ Photos/
  echo 
  echo ------------ Seagate Photos to Time Machine ------------
  echo
  rsync -ahL --progress /Volumes/Seagate/Photos/ /Volumes/Time\ Machine/Photos/
  echo 
  echo ------------ Seagate Wedding Video to Time Machine ------------
  echo
  rsync -ahL --progress /Volumes/Seagate/Wedding\ Video/ /Volumes/Time\ Machine/Wedding\ Video/
}

gd() {
  git diff HEAD
}

gla() {
  find . -maxdepth 1 -mindepth 1 -type d -exec sh -c '(echo {} && cd {} && git pull && echo)' \;
}

glu() {
  git checkout master
  git pull
  git checkout -
}

gpd() {
  git push
  make deploy
}

gpf() {
  git pushf
}

gsa() {
  find . -maxdepth 1 -mindepth 1 -type d -exec sh -c '(echo {} && cd {} && git status && echo)' \;
}

m() {
  if [ "$@" ] ; then
    mvim $@
  else
    mvim .
  fi
}

npmrc-hs() {
  cp ~/.npmrc-hs ~/.npmrc
}

npmrc-reset() {
  rm ~/.npmrc
}

o() {
  if [ "$@" ] ; then
    xdg-open $@
  else
    xdg-open .
  fi
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

ti() {
  tmux new-session -d -s primary -n shell
  tmux split-window -t primary -h
  tmux attach
}

# Import private settings

source ~/Sources/dotfiles-private/zshrc
source ~/.zshrc-env
