# Environment variables

export EDITOR='vim'
export PYENV_ROOT="$HOME/.pyenv"
export PATH=$PATH:~/$PYENV_ROOT/bin:~/Sources/dotfiles/bin:~/.local/bin
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
alias n='vim ~/Dropbox/Documents/Misc/Notes.txt'
alias o='open'
alias ta='tmux attach -t'
unalias gd
unalias gpd

# Prompt

autoload -U promptinit; promptinit
prompt pure

# Python

if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

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

m() {
  if [ "$@" ] ; then
    gvim $@
  else
    gvim .
  fi
}

ti() {
  tmux new-session -d -s primary -n shell
  tmux split-window -t primary -h
  tmux attach
}

# Import private settings

source ~/Sources/dotfiles-private/zshrc
