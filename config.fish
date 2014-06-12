# Server or not? {{{

set IS_SERVER 'false'
switch (hostname)
    case 'box.nicksergeant.com'
        set IS_SERVER 'true'
end

# }}}

# Bind Keys {{{

function fish_user_keybindings
    bind \cn accept-autosuggestion

    # Ignore iterm2 escape sequences.  Vim will handle them if needed.
    bind \e\[I true
    bind \e\[O true
    # ]]
end

# }}}
# Ctags {{{

function atags
    unlink media/js/closure-library;
    ctags -R .;
    jsctags media/js -f jstags --ignore 'jquery|.*closure.*|.*.un~|.*.min.js|amara.js|popcorn.js|mirosubs-statwidget.js|unisubs-calcdeps.js|unisubs-statwidget.js';
    cat jstags >> tags;
    rm jstags;
    ln -s /opt/google-closure media/js/closure-library;
end

function stags
    ctags -R .;
    jsctags media/js -f jstags --ignore 'jquery|codemirror|media/js/snipt.js|.*.un~|.*.min.js';
    cat jstags >> tags;
    rm jstags;
end

# }}}
# Directories {{{

function l
    tree --dirsfirst -ChFL 1 $args
end
function ll
    tree --dirsfirst -ChFupDaL 1 $args
end

function logs
    cd /Users/Nick/Sources/dotfiles-private/weechat/logs
end

function jslines
    find . -name '*.js' | xargs wc -l
end

# }}}
# Edit file functions {{{

function ef
    mvim ~/.config/fish/config.fish
end
function ev
    mvim ~/.vimrc
end

# }}}
# Environment variables {{{

set TMPDIR "/tmp"
set PATH "/usr/local/bin"          $PATH
set PATH "/usr/local/sbin"         $PATH

if test $IS_SERVER = 'false'
    set BROWSER open
    set PATH "/usr/local/opt/ruby/bin" $PATH
    set PATH "/Applications/Postgres.app/Contents/MacOS/bin" $PATH
    set PATH "/Users/Nick/Sources/dotfiles/bin" $PATH
    set PATH "/usr/local/share/npm/bin" $PATH
    set PATH "/Users/Nick/Android/sdk/tools" $PATH
    set PATH "/Users/Nick/Android/sdk/platform-tools" $PATH
else
    set PATH "/usr/local/lib/node_modules" $PATH
end

set -g -x fish_greeting ''
set -g -x EDITOR vim
set -g -x NODE_PATH "/usr/local/lib/node_modules"
set -g -x NODE_PATH "/usr/local/lib/jsctags/" $NODE_PATH

# }}}
# Git and Mercurial functions {{{

if test $IS_SERVER = 'false'
    function git
        hub $argv
    end
end
function gpds
    git push; gulp deploy --env=staging
end
function g 
    git $argv
end
function gm
    git co master $argv
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
function gll 
    git submodule foreach git pull $argv
end
function glc 
    /Users/Nick/Sources/dotfiles/bin/get_last_commit | pbcopy $argv
end
function glco 
    git browse -- commit/(/Users/Nick/Sources/dotfiles/bin/get_last_commit) $argv
end
function glu
    git checkout master;
    git pull;
    git checkout -;
end
function gp 
    git push $argv
end
function gst 
    git status $argv
end
function i
    ghi $argv
end
function ic
    if test $argv
      ghi comment -l $argv
    else
      ghi comment -l (git currentbranch ^/dev/null) $argv
    end
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
    if test $argv
      ghi show $argv
    else
      ghi show (git currentbranch ^/dev/null) $argv
    end
end
function io
    if test $argv
      ghi show -w $argv
    else
      ghi show (git currentbranch ^/dev/null) -w $argv
    end
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
    cd ~/Code/awsm; script/bootstrap; bundle exec rake awsm:mocked;
end
function c 
    pygmentize -O style=monokai -f console256 -g $argv
end
function ce 
    /Users/Nick/Code/unisubs/media/js/embedder/compile-embedder.sh $argv
end
function deact 
    deactivate $argv
end
function gpd
    git push; make deploy;
end
function doge
    suchvalue DAqKq1SG9abegwcpPEcdmYsr4NWfZSZLA6=dogehouse DAYrpmB2mVGZeRdLRmz2Jwf5VccN7t3nRf=cryptsy DT45nQ43qBCGbPS9ud4JXBKAMUMsnq6MuU=suchvalue DEm9MsUZ3U6mLhX1oi4QKmW6wNbB7fxeZH=dogetipbot DSwDw22PgAHD6wLzh6x2aSBuZSagM2EMKn=tipdoge DFebfjwBLp248Rr4fZ3yXJHg4B25N9Npau=cryptsy_fork
end
function h 
    heroku $argv
end
function ip 
    http icanhazip.com $argv
end
function m
    mvim . $argv
end
function mc 
    telnet localhost 11211 $argv
end
function mk 
    mkdir -p $argv
end
function mutt
    bash --login -c 'cd ~/Downloads; /usr/local/bin/mutt' $argv;
end
function network_usage 
    lsof -i | grep -E "(LISTEN|ESTABLISHED)" $argv
end
function o 
    open $argv
end
function oo 
    open . $argv
end
function pbc 
    pbcopy $argv
end
function pbp 
    pbpaste $argv
end
function p
    dtach -A /tmp/pianobar pianobar
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
function sg
    sgcli $argv
end
function sleep
    sudo dbus-send --system --print-reply --dest="org.freedesktop.UPower" /org/freedesktop/UPower org.freedesktop.UPower.Suspend
end
function swift
    xcrun swift
end
function syncdrives 
    sudo rsync -avP /Volumes/Story/ /Volumes/Seagate $argv
end
function ta 
    tmux attach -t $argv
end
function tk 
    tmux kill-session -t $argv
end
function tn 
    tmux new -s $argv
end
function ul 
    unlink $argv
end
function vim
    mvim -v $argv
end
function v
    vagrant $argv
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
function vst
    vagrant status $argv
end
function virtualbox_shut_down_or_i_will_fucking_cut_you
    VBoxManage controlvm $argv poweroff $argv
end
function virtualbox_shut_down_or_i_will_fucking_cut_you
    VBoxManage controlvm $argv poweroff
end
function wo 
    workon (cat .venv) $argv
end
function wakepc
    wakeonlan 68:b5:99:d3:ab:35
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
    if test $PWD = '/Users/Nick/Code/broker'
        set -l CUR (git currentbranch ^/dev/null)
        printf ' \033[0;37mon '
        printf '\033[0;35m%s' $CUR
        printf ' \033[0;32m'
        git_prompt_status
    end
    if test $PWD = '/Users/Nick/Code/cds'
        set -l CUR (git currentbranch ^/dev/null)
        printf ' \033[0;37mon '
        printf '\033[0;35m%s' $CUR
        printf ' \033[0;32m'
        git_prompt_status
    end
    if test $PWD = '/Users/Nick/Code/collabmatch'
        set -l CUR (git currentbranch ^/dev/null)
        printf ' \033[0;37mon '
        printf '\033[0;35m%s' $CUR
        printf ' \033[0;32m'
        git_prompt_status
    end
    if test $PWD = '/Users/Nick/Code/kony'
        set -l CUR (git currentbranch ^/dev/null)
        printf ' \033[0;37mon '
        printf '\033[0;35m%s' $CUR
        printf ' \033[0;32m'
        git_prompt_status
    end
    if test $PWD = '/Users/Nick/Code/nextgen-ui'
        set -l CUR (git currentbranch ^/dev/null)
        printf ' \033[0;37mon '
        printf '\033[0;35m%s' $CUR
        printf ' \033[0;32m'
        git_prompt_status
    end
    if test $PWD = '/Users/Nick/Code/publet'
        set -l CUR (git currentbranch ^/dev/null)
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
    if test $IS_SERVER = 'true'
        printf '\033[0;31m%s ' (hostname -f)
    else
        printf '\033[0;33m%s ' (hostname -f)
    end
    printf '\033[0;32m%s' (prompt_pwd)
    git_prompt
    echo
    virtualenv_prompt
    printf '\033[0;37m> '
end

# }}}
# Python variables {{{

set -g -x PIP_DOWNLOAD_CACHE "$HOME/.pip/cache"

if test $IS_SERVER = 'false'
    set PATH "/usr/local/opt/ruby/bin" $PATH
    set -g -x PYTHONPATH ""
    set PYTHONPATH "$PYTHONPATH:/usr/local/lib/python2.7/site-packages"
end

set -g -x WORKON_HOME "$HOME/.virtualenvs"
source ~/.config/fish/virtualenv.fish

# }}}
# Ruby {{{

if test $IS_SERVER = 'false'
    set -x PATH $HOME/.rbenv/bin $PATH
    set -x PATH $HOME/.rbenv/shims $PATH
    rbenv rehash >/dev/null ^&1
end

function rbenv_shell
  set -l vers $argv[1]

  switch "$vers"
    case '--complete'
      echo '--unset'
      echo 'system'
      command rbenv versions --bare
      return
    case '--unset'
      set -e RBENV_VERSION
      return 1
    case ''
      if [ -z "$RBENV_VERSION" ]
        echo "rbenv: no shell-specific version configured" >&2
        return 1
      else
        echo "$RBENV_VERSION"
        return
      end
    case '*'
      rbenv prefix "$vers" > /dev/null
      set -gx RBENV_VERSION "$vers"
  end
end

function rbenv_lookup
  set -l vers (command rbenv versions -- bare| sort | grep -- "$argv[1]" | tail -n1)

  if [ ! -z "$vers" ]
    echo $vers
    return
  else
    echo $argv
    return
  end
end

function rbenv
  set -l command $argv[1]
  [ (count $argv) -gt 1 ]; and set -l args $argv[2..-1]

  switch "$command"
    case shell
      rbenv_shell (rbenv_lookup $args)
    case local global
      command rbenv $command (rbenv_lookup $args)
    case '*'
      command rbenv $command $args
  end
end

# }}}
# Server functions {{{

function n
    ssh nick@box.nicksergeant.com $argv
end
function b
    ssh nick@broker.is
end
function c
    ssh nick@new.compliantdatasystems.com
end
function cds
    cd ~/Code/cds; make run;
end
function broker
    cd ~/Code/broker; make run;
end
function collabmatch
    sudo killall node -15; cd ~/Code/collabmatch; gulp;
end
function fitzlimo
    sudo killall node -15; cd ~/Code/fitzlimo; nodemon -x node server &; cd client; gulp watch;
end
function pool
    ssh pool@pool.coinminery.com $argv
end
function snipt
    cd ~/Code/snipt; workon snipt; pm runserver 3000;
end
function ui
    sudo killall node -9; cd ~/Code/nextgen-ui/api; nodemon server &; cd ../server; sudo nodemon server;
end
function remap
    launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.offline-imap.plist; launchctl load ~/Library/LaunchAgents/homebrew.mxcl.offline-imap.plist;
end

# }}}
# Tmux {{{

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

# }}}
# Z {{{

if test $IS_SERVER = 'true'
    source ~/sources/z-fish/z.fish
else
    source ~/Sources/z-fish/z.fish
end

function j
    z $argv
end

# }}}

source ~/Sources/dotfiles-private/config.fish
