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

function ..
    cd ..
end
function ...
    cd ../..
end
function ...
    cd ../../..
end
function .....
    cd ../../../..
end

function l1 
    tree --dirsfirst -ChFL 1
end

function ll1
    tree --dirsfirst -ChFupDaL 1
end

function l
    l1
end
function ll 
    ll1
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
    set PATH "/usr/local/Cellar/ruby/1.9.3-p194/bin" $PATH
    set PATH "/usr/local/Cellar/ruby/1.9.3-p286/bin" $PATH
    set PATH "/Applications/Postgres.app/Contents/MacOS/bin" $PATH
    set PATH "/Users/Nick/Sources/dotfiles/bin" $PATH
    set PATH "/usr/local/share/python" $PATH
    set PATH "/usr/local/share/npm/bin" $PATH
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
function g
    git $argv
end
function gca 
    git commit -a $argv
end
function gco 
    git checkout $argv
end
function gd 
    git diff $argv
end
function gdd 
    git difftool $argv
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
function gmid 
    git co dev; git fetch origin; git merge --ff-only origin/dev; git merge --no-ff staging; git co staging $argv
end
function gp 
    git push $argv
end
function gs 
    git show $argv
end
function gst 
    git status $argv
end
function hgc 
    hg commit $argv
end
function hgs 
    hg st $argv
end
function hgp 
    hg push $argv
end
function hgl 
    hg pull $argv
end
function hglu 
    hg pull -u $argv
end

# }}}
# Program functions {{{

function c 
    pygmentize -O style=monokai -f console256 -g $argv
end
function ce 
    /Users/Nick/Code/unisubs/media/js/embedder/compile-embedder.sh $argv
end
function deact 
    deactivate $argv
end
function es 
    elasticsearch -f -D es.config=/usr/local/Cellar/elasticsearch/0.19.8/config/elasticsearch.yml $argv
end
function est 
    elasticsearch -f -D es.config=/Users/Nick/Code/tred/elasticsearch.yml $argv
end
function go 
    vagrant ssh; $argv
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
function pm 
    python manage.py $argv
end
function ssc 
    sudo supervisorctl $argv
end
function syncdrives 
    sudo rsync -avP /Volumes/Story/ /Volumes/Seagate $argv
end
function t 
    tmux $argv
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
function vu 
    vagrant up $argv
end
function vh 
    vagrant halt $argv
end
function vs 
    vagrant suspend $argv
end
function wo 
    workon (cat .venv) $argv
end

function virtualbox_shut_down_or_i_will_fucking_cut_you
    VBoxManage controlvm $argv poweroff $argv
end

function mutt
    bash --login -c 'cd ~/Desktop; /usr/local/bin/mutt' $argv;
end

function pp
    pbpaste|scli post_and_get_url -t|pbcopy;
    printf '\033[0;36mCopied:\033[0;37m %s\n' (pbpaste);
end

# }}}
# Prompt {{{

function virtualenv_prompt
    if [ -n "$VIRTUAL_ENV" ]
        printf '\033[0;37m(%s) ' (basename "$VIRTUAL_ENV") $argv
    end
end

function git_prompt
    if test $PWD = '/Users/Nick/Code/unisubs'
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
    if test $IS_SERVER = 'true'
        printf '\033[0;31m%s ' (hostname|cut -d . -f 1)
    else
        printf '\033[0;33m%s ' (hostname|cut -d . -f 1)
    end
    printf '\033[0;32m%s' (prompt_pwd)
    git_prompt
    echo
    virtualenv_prompt
    printf '\033[0;37m○ '
end

# }}}
# Python variables {{{

set -g -x PIP_DOWNLOAD_CACHE "$HOME/.pip/cache"

if test $IS_SERVER = 'false'
    set PATH "/usr/local/share/python"            $PATH
    set PATH "/usr/local/Cellar/python/2.7.3/bin" $PATH

    set -g -x PYTHONPATH ""
    set PYTHONPATH "$PYTHONPATH:/usr/local/lib/python2.7.3/site-packages"
end

set -g -x WORKON_HOME "$HOME/.virtualenvs"
. ~/.config/fish/virtualenv.fish

# }}}
# Server functions {{{

function afa 
    ssh nick@afeedapart.com $argv
end
function box
    ssh nick@box.nicksergeant.com $argv
end

# }}}
# Z {{{

if test $IS_SERVER = 'true'
    . ~/sources/z-fish/z.fish
else
    . ~/Sources/z-fish/z.fish
end

function j
    z $argv
end

# }}}
