# Server or not? {{{

set IS_SERVER 'false'
switch (hostname)
    case 'ec2.nicksergeant.com'
        set IS_SERVER 'true'
    case 'snipt.net'
        set IS_SERVER 'true'
    case 'snipt.nicksergeant.com'
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

alias ..    'cd ..'
alias ...   'cd ../..'
alias ....  'cd ../../..'
alias ..... 'cd ../../../..'

alias l1 'tree --dirsfirst -ChFL 1'
alias l2 'tree --dirsfirst -ChFL 2'
alias l3 'tree --dirsfirst -ChFL 3'
alias l4 'tree --dirsfirst -ChFL 4'
alias l5 'tree --dirsfirst -ChFL 5'
alias l6 'tree --dirsfirst -ChFL 6'

alias ll1 'tree --dirsfirst -ChFupDaL 1'
alias ll2 'tree --dirsfirst -ChFupDaL 2'
alias ll3 'tree --dirsfirst -ChFupDaL 3'
alias ll4 'tree --dirsfirst -ChFupDaL 4'
alias ll5 'tree --dirsfirst -ChFupDaL 5'
alias ll6 'tree --dirsfirst -ChFupDaL 6'

alias l  'l1'
alias ll 'll1'

alias u 'cd /Users/Nick/Code/unisubs'
alias s 'cd /Users/Nick/Code/snipt'

# }}}
# Edit file aliases {{{

alias ef 'mvim ~/.config/fish/config.fish'
alias ev 'mvim ~/.vimrc'

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
# Git and Mercurial aliases {{{

if test $IS_SERVER = 'false'
    alias git 'hub'
end
alias g 'git'
alias gca 'git commit -a'
alias gco 'git checkout'
alias gd 'git diff'
alias gdd 'git difftool'
alias gl 'git pull'
alias gll 'git submodule foreach git pull'
alias glc '/Users/Nick/Sources/dotfiles/bin/get_last_commit | pbcopy'
alias glco 'git browse -- commit/(/Users/Nick/Sources/dotfiles/bin/get_last_commit)'
alias gmid 'git co dev; git fetch origin; git merge --ff-only origin/dev; git merge --no-ff staging; git co staging'
alias gp 'git push'
alias gs 'git show'
alias gst 'git status'
alias hgc 'hg commit'
alias hgs 'hg st'
alias hgp 'hg push'
alias hgl 'hg pull'
alias hglu 'hg pull -u'

# }}}
# Program aliases {{{

alias c 'pygmentize -O style=monokai -f console256 -g'
alias ce '/Users/Nick/Code/unisubs/media/js/embedder/compile-embedder.sh'
alias deact 'deactivate'
alias es 'elasticsearch -f -D es.config=/usr/local/Cellar/elasticsearch/0.19.8/config/elasticsearch.yml'
alias est 'elasticsearch -f -D es.config=/Users/Nick/Code/tred/elasticsearch.yml'
alias go 'vagrant ssh;'
alias ip 'http icanhazip.com'
#alias m 'tmux new-window -t vim -n (basename (pwd)) "vim $PWD"; tmux switch -t vim'
alias m 'mvim .'
alias mc 'telnet localhost 11211'
alias mk 'mkdir -p'
alias network_usage 'lsof -i | grep -E "(LISTEN|ESTABLISHED)"'
alias o 'open'
alias oo 'open .'
alias pbc 'pbcopy'
alias pbp 'pbpaste'
alias pm 'python manage.py'
alias ssc 'sudo supervisorctl'
alias syncdrives 'sudo rsync -avP /Volumes/Story/ /Volumes/Seagate'
alias t 'tmux'
alias ta 'tmux attach -t'
alias tk 'tmux kill-session -t'
alias tn 'tmux new -s'
alias ul 'unlink'
alias vu 'vagrant up'
alias vh 'vagrant halt'
alias vs 'vagrant suspend'
alias wo 'workon (cat .venv)'

function virtualbox_shut_down_or_i_will_fucking_cut_you
    VBoxManage controlvm $argv poweroff
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
        printf '\033[0;37m(%s) ' (basename "$VIRTUAL_ENV")
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
    echo
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
# Server aliases {{{

alias air 'ssh Nick@air.local'
alias afa 'ssh nick@afeedapart.com'
alias ec 'ssh nick@ec2.nicksergeant.com'
alias gf 'ssh nick@garthfagandance.org'
alias pro 'ssh Nick@pro.local'
alias sn 'ssh nick@snipt.net'

# }}}
# Z {{{

. ~/Sources/z-fish/z.fish

alias j 'z'

# }}}
