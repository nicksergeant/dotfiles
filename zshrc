# Environment variables

export EDITOR='vim'
export ZSH=/Users/nsergeant/.oh-my-zsh

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
alias m='mvim .'
alias o='open'
alias ta='tmux attach -t'
unalias gpd

# Prompt

autoload -U promptinit; promptinit
prompt pure

# Functions

bu() {
  echo ------------ App Databases ------------
  echo
  budb
  echo 
  echo ------------ Mac Dropbox to Seagate ------------
  echo
  rsync -ahL --progress ~/Dropbox/ /Volumes/Seagate/Dropbox/
  echo 
  echo ------------ Mac Dropbox to Time Machine ------------
  echo
  rsync -ahL --progress ~/Dropbox/ /Volumes/Time\ Machine/Dropbox/
  echo 
  echo ------------ Mac iCloud Drive to Seagate ------------
  echo
  rsync -ahL --progress ~/Library/Mobile\ Documents/com~apple~CloudDocs/ /Volumes/Seagate/iCloud\ Drive/
  echo 
  echo ------------ Mac iCloud Drive to Time Machine ------------
  echo
  rsync -ahL --progress ~/Library/Mobile\ Documents/com~apple~CloudDocs/ /Volumes/Time\ Machine/iCloud\ Drive/
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

ti() {
  tmux new-session -d -s primary -n shell
  tmux split-window -t primary -h
  tmux attach
}

# Import private settings

source ~/Sources/dotfiles-private/zshrc
