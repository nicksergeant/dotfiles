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
set PATH "/Users/Nick/.rvm/bin" $PATH

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
function gb
  git browse
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
  p2
  git browse -- commit/(~/Sources/dotfiles/bin/get_last_commit) $argv
  p
end
function glu
  git checkout master;
  git pull;
  git checkout -;
end
function gp 
  git push $argv
end
function dp 
  desk-flow ticket submit
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
# Go {{{

set -x GOPATH '/Users/Nick/.go'
set PATH "/Users/Nick/.go/bin" $PATH

# }}}
# Program functions {{{

function desk-rails
  cd /dev_exclusions/assistly;
  rvm use 2.1.5 --default;
  mysql.server start;
  bundle install;
  foreman start;
end
function desk-rails-logs
  cd /dev_exclusions/assistly;
  tail -f log/development.log;
end
function desk-reporting-updater
  cd /dev_exclusions/reporting_updater;
  rvm use 2.1.5 --default;
  bin/bundle exec ./bin/reporting_updater run
end
function desk-webclient
  cd /dev_exclusions/webclient;
  rvm use 2.1.5 --default;
  bundle install;
  foreman start;
end
function desk-haproxy
  cd /dev_exclusions/webclient;
  sudo haproxy -f config/haproxy.cfg;
end
function desk-zeus
  cd /dev_exclusions/assistly;
  rvm use 2.1.5 --default;
  bundle exec zeus start;
end
function desk-zeus-server
  cd /dev_exclusions/assistly;
  rvm use 2.1.5 --default;
  bundle exec zeus server;
end
function gpd
  git push; make deploy;
end
function deact
  deactivate;
end
function dokku
  ssh dokku@dokku.nicksergeant.com $argv;
end
function doge
  suchvalue DAqKq1SG9abegwcpPEcdmYsr4NWfZSZLA6=dogehouse DAYrpmB2mVGZeRdLRmz2Jwf5VccN7t3nRf=cryptsy DT45nQ43qBCGbPS9ud4JXBKAMUMsnq6MuU=suchvalue DEm9MsUZ3U6mLhX1oi4QKmW6wNbB7fxeZH=dogetipbot DSwDw22PgAHD6wLzh6x2aSBuZSagM2EMKn=tipdoge DFebfjwBLp248Rr4fZ3yXJHg4B25N9Npau=cryptsy_fork
end
function fitocracy_cookie_update
  set pasted = (pbpaste); dokku config:set slacktocracy-amara FITOCRACY_COOKIE="'$pasted'";
  set pasted = (pbpaste); dokku config:set slacktocracy-siftie FITOCRACY_COOKIE="'$pasted'";
  set -e pasted;
end
function gif
  giffify ~/Temp/Untitled.mov ~/Temp/gif.gif
  rm ~/Temp/Untitled.mov
  open -a CloudApp ~/Temp/gif.gif
end
function d
  cd ~/Code/ndebug; mvim .
end
function e
  cd ~/Code/edebug; mvim .
end
function lea
  cd ~/Code/leather;
  p;
  wo;
  pm runserver;
end
function m
  p2
  mvim . $argv
  p
end
function mutt
  bash --login -c 'cd ~/Downloads; /usr/local/bin/mutt' $argv;
end
function o
  open $argv
end
function p
  set -x PYTHONPATH ':/usr/local/lib/python3.5/site-packages'
end
function p2
  set -x PYTHONPATH ':/usr/local/lib/python2.7/site-packages'
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
function sif
  cd ~/Code/siftie; meteor run --port 4000
end
function suk
  sudo killall -9 node
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
  # Primary
  tmux new-session -d -s primary -n servers
  tmux split-window -t primary -v
  tmux split-window -t primary -h
  tmux split-window -t primary -h
  sleep 1
  tmux select-layout tiled
  tmux send-keys -t 1 desk-rails ENTER
  tmux send-keys -t 2 desk-haproxy ENTER
  tmux send-keys -t 3 desk-webclient ENTER

  # Zeus
  tmux new-window -t primary -a -n zeus
  tmux split-window -t zeus -h
  tmux split-window -t zeus -v
  tmux resize-pane -t 1 -L 1
  tmux send-keys -t 2 desk-zeus ENTER
  sleep 2
  tmux send-keys -t 1 desk-zeus-server ENTER

  # Logs
  tmux new-window -t primary -a -n logs
  tmux split-window -t logs -h
  tmux split-window -t logs -v
  tmux resize-pane -t 1 -L 1
  tmux send-keys -t 1 desk-rails-logs ENTER
  tmux send-keys -t 2 desk-reporting-updater ENTER

  # Shell
  tmux new-window -t primary -a -n shell
  tmux split-window -t shell -v
  tmux send-keys -t 1 'cd /dev_exclusions/assistly' ENTER
  tmux send-keys -t 2 'cd /dev_exclusions/webclient' ENTER
  tmux attach
end
function tih
  tmux new-session -d -s primary -n shell
  tmux split-window -t primary -h
  tmux attach
end
function vim
  p2
  /usr/local/bin/vim $argv
  p
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
  printf '\033[0;33m%s ' (hostname -f)
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
# Ruby {{{

set PATH $HOME/.rbenv/bin $PATH
set PATH $HOME/.rbenv/shims $PATH
rbenv rehash >/dev/null ^&1
# set -x SSL_CERT_FILE /usr/local/etc/cacert.pem

# }}}
# VMs and servers {{{

function ssh
  switch "$argv"
    case 'ubuntu'
      ssh nick@ubuntu.local
    case 'snipt'
      ssh nick@server.snipt.net
    case 'broker'
      ssh nick@broker.is
    case 'dokku'
      ssh nick@dokku.nicksergeant.com
    case 'cds'
      ssh nick@compliantdatasystems.com
    case 'humanitybox'
      ssh nick@humanitybox.com
    case 'leather'
      ssh nick@leatherapp.com
    case 'nicksergeant'
      ssh root@server.nicksergeant.com
    case 'ng-job'
      ssh nick@ng-job.com
    case 'siftie'
      ssh root@siftie.com
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
function loc
  cd ~/Code/localytics-rails;
  bundle install;
  bundle exec rake db:migrate;
  bundle exec rails s;
end
function locj
  cd ~/Code/localytics-rails;
  npm install;
  npm run assets:hot
end
function cl
  cd ~/Code/localytics-rails;
  git checkout Gemfile;
  git checkout Gemfile.lock;
  git checkout db/structure.sql;
end

# }}}
# Z {{{

source ~/Sources/z-fish/z.fish

function j
  z $argv
end

# }}}

source ~/Sources/dotfiles-private/config.fish
set -x PYTHONPATH ':/usr/local/lib/python3.5/site-packages'
alias python=python3
rvm default
