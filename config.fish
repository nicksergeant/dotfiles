# Bind Keys {{{

function fish_user_keybindings
  bind \cn accept-autosuggestion
  bind \e\[I true
  bind \e\[O true
  # ]]
end

# }}}
# Directories {{{

function l
  tree --dirsfirst -ChFL 1 $args
end
function ll
  tree --dirsfirst -ChFupDaL 1 $args
end

# }}}
# Docker {{{

set -x DOCKER_HOST tcp://192.168.59.103:2376
set -x DOCKER_CERT_PATH /Users/Nick/.boot2docker/certs/boot2docker-vm
set -x DOCKER_TLS_VERIFY 1

# }}}
# Environment variables {{{

set TMPDIR "/tmp"
set PATH "/usr/local/bin" $PATH
set PATH "/usr/local/sbin" $PATH

set BROWSER open
set PATH "/usr/local/opt/ruby/bin" $PATH
set PATH "/Users/Nick/Sources/dotfiles/bin" $PATH
set PATH "/usr/local/share/npm/bin" $PATH

set -g -x fish_greeting ''
set -g -x EDITOR vim
set -g -x NODE_PATH "/usr/local/lib/node_modules"

# }}}
# Git and Mercurial functions {{{

function git
  hub $argv
end
function gca 
  git commit -a $argv
end
function gc 
  git compare (git rev-parse --abbrev-ref HEAD)
end
function gco 
  git checkout $argv
end
function gd 
  git diff HEAD
end
function gl
  git pull $argv
end
function glco 
  git browse -- commit/(/Users/Nick/Sources/dotfiles/bin/get_last_commit) $argv
end
function glu
  git checkout master;
  git pull;
  git checkout -;
end
function go
  git browse
end
function gp 
  git push $argv
end
function gst 
  git status $argv
end

# }}}
# GitHub Issues {{{

function i
  ghi $argv
end
function ic
  ghi comment -l $argv
end
function ilm
  ghi list --mine $argv
end
function il
  ghi list $argv
end
function ilo
  ghi list -w $argv
end
function is
  ghi show $argv
end
function io
  ghi show -w $argv
end
function ild
  ghi list --milestone --label dev
end
function ila
  ghi list --all --mine $argv
end

# }}}
# Program functions {{{

function awsm
  cd ~/Code/awsm; bundle install; bundle exec rake awsm:mocked;
end
function gpd
  git push; make deploy;
end
function deact
  deactivate;
end
function doge
  suchvalue DAqKq1SG9abegwcpPEcdmYsr4NWfZSZLA6=dogehouse DAYrpmB2mVGZeRdLRmz2Jwf5VccN7t3nRf=cryptsy DT45nQ43qBCGbPS9ud4JXBKAMUMsnq6MuU=suchvalue DEm9MsUZ3U6mLhX1oi4QKmW6wNbB7fxeZH=dogetipbot DSwDw22PgAHD6wLzh6x2aSBuZSagM2EMKn=tipdoge DFebfjwBLp248Rr4fZ3yXJHg4B25N9Npau=cryptsy_fork
end
function m
  mvim . $argv
end
function mutt
  bash --login -c 'cd ~/Downloads; /usr/local/bin/mutt' $argv;
end
function o
  open $argv
end
function pbc 
  pbcopy $argv
end
function pbp
  pbpaste $argv
end
function pm
  python manage.py $argv
end
function lisp
  rlwrap sbcl
end
function ssc
  sudo supervisorctl -c /Users/Nick/Sources/dotfiles-private/supervisor/supervisord.conf $argv
end
function swift
  xcrun swift
end
function ta 
  tmux attach -t $argv
end
function ti
  tmux new-session -d -s primary
  tmux rename-window -t primary mutt
  tmux send -t primary mutt ENTER
  tmux new-window -t primary -a -n weechat 'weechat-curses'
  sleep .3
  tmux rename-window -t primary weechat
  tmux set -t primary window-status-format "#[fg=white,bg=colour234] #W "
  tmux new-window -t primary -a -n shell
  tmux split-window -t primary -h
  tmux attach
end
function vim
  mvim -v $argv
end
function vu
  vagrant up $argv
end
function vh
  vagrant halt $argv
end
function vs
  vagrant up; vagrant ssh $argv
end
function virtualbox_shut_down_or_i_will_fucking_cut_you
  VBoxManage controlvm $argv poweroff $argv
end
function wo 
  workon (cat .venv) $argv
end

# }}}
# Prompt {{{

set -x fish_color_command 005fd7\x1epurple
set -x fish_color_search_match --background=purple

function virtualenv_prompt
  if [ -n "$VIRTUAL_ENV" ]
    printf '\033[0;37m(%s) ' (basename "$VIRTUAL_ENV") $argv
  end
end

function git_prompt
  set -l CUR (git currentbranch ^/dev/null)
  if test $CUR
    printf ' \033[0;37mon '
    printf '\033[0;35m%s' $CUR
    printf ' \033[0;32m'
    git_prompt_status
  end
end

function prompt_pwd --description 'Print the current working directory, shortend to fit the prompt'
  echo $PWD | sed -e "s|^$HOME|~|"
end

function fish_prompt
  z --add "$PWD"
  echo ' '
  printf '\033[0;33m%s\033[0;37m on ' (whoami)
  printf '\033[0;33m%spro.local '
  printf '\033[0;32m%s' (prompt_pwd)
  git_prompt
  echo
  virtualenv_prompt
  printf '\033[0;37m> '
end

# }}}
# Python variables {{{

set -g -x PIP_DOWNLOAD_CACHE "$HOME/.pip/cache"
set PATH "/usr/local/opt/ruby/bin" $PATH
set -g -x PYTHONPATH ""
set PYTHONPATH "$PYTHONPATH:/usr/local/lib/python2.7/site-packages"
set -g -x WORKON_HOME "$HOME/.virtualenvs"
source ~/.config/fish/virtualenv.fish

# }}}
# VMs and servers {{{

function ssh
  switch "$argv"
    case 'media'
      ssh nick@media.local
    case 'snipt'
      ssh nick@server.snipt.net
    case 'broker'
      ssh nick@broker.is
    case 'cds'
      ssh nick@new.compliantdatasystems.com
    case 'humanitybox'
      ssh nick@humanitybox.com
    case 'nicksergeant'
      ssh root@server.nicksergeant.com
    case 'ng-job'
      ssh nick@ng-job.com
    case 'siftie'
      ssh root@server.sift.ie
    case 'showroom'
      ssh root@server.showroom.is
    case '*'
      /usr/bin/ssh $argv
  end
end
function vm
  cd ~/Code/$argv; make run;
end

function collabmatch
  sudo killall node -15; cd ~/Code/collabmatch; gulp;
end
function fitzlimo
  sudo killall node -15; cd ~/Code/fitzlimo; nodemon -x node server &; cd client; gulp watch;
end
function stone
  cd /Users/Nick/Code/stonevault/vault;
  workon stonevault;
  set -x DJANGO_SETTINGS_MODULE 'config.dev.settings';
  set -x PYTHONPATH ':/usr/local/lib/python2.7/site-packages:/Users/Nick/Code/stonevault:/Users/Nick/Code/stonevault/vault:/Users/Nick/Code/stonevault/vault/apps:/Users/Nick/Code/stonevault/vault/apps/config';
  django-admin.py runserver;
end
function ui
  sudo killall vmnet-natd;
  sudo killall node -9;
  cd ~/Code/nextgen-ui/api;
  supervisor server &
  cd ../;
  sudo supervisor -e node,js,json -i .git,api,client,node_modules,script,tests,translations server/server.js
end

# }}}
# Z {{{

source ~/Sources/z-fish/z.fish

function j
  z $argv
end

# }}}

source ~/Sources/dotfiles-private/config.fish
