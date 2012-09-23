# Server or not?
set IS_SERVER 'false'
switch (hostname)
    case 'ec2.nicksergeant.com'
        set IS_SERVER 'true'
    case 'snipt.net'
        set IS_SERVER 'true'
end

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
set PATH "/usr/local/share/python" $PATH
set PATH "/usr/local/Cellar/ruby/1.9.3-p194/bin" $PATH
set PATH "/Users/Nick/Sources/dotfiles/bin" $PATH
set PATH "/Applications/Postgres.app/Contents/MacOS/bin" $PATH
set BROWSER open

set -g -x fish_greeting ''
set -g -x EDITOR vim
set -g -x NODE_PATH "/usr/local/lib/node_modules"
set -g -x NODE_PATH "/usr/local/lib/jsctags/" $NODE_PATH

# }}}
# Git and Mercurial aliases {{{

if test $IS_SERVER = 'false'
    alias git 'hub'
end
alias gca 'git commit -a'
alias gd 'git difftool'
alias gl 'git pull'
alias gll 'git submodule foreach git pull'
alias glc '/Users/Nick/Sources/dotfiles/bin/get_last_commit | pbcopy'
alias glco 'git browse -- commit/(/Users/Nick/Sources/dotfiles/bin/get_last_commit)'
alias gp 'git push'
alias gst 'git status'
alias hgc 'hg commit'
alias hgs 'hg st'
alias hgp 'hg push'
alias hgl 'hg pull'
alias hglu 'hg pull -u'

# }}}
# Program aliases {{{

alias ce '/Users/Nick/Code/unisubs/media/js/embedder/compile-embedder.sh'
alias deact 'deactivate'
alias es 'elasticsearch -f -D es.config=/usr/local/Cellar/elasticsearch/0.19.8/config/elasticsearch.yml'
alias go 'vagrant ssh;'
alias ip 'http icanhazip.com'
alias m 'mvim .'
alias mc 'telnet localhost 11211'
alias mk 'mkdir -p'
alias network_usage 'lsof -i | grep -E "(LISTEN|ESTABLISHED)"'
alias o 'open'
alias oo 'open .'
alias pbc 'pbcopy'
alias pbp 'pbpaste'
alias pm 'python manage.py'
alias ul 'unlink'
alias vu 'vagrant up'
alias vh 'vagrant halt'
alias vs 'vagrant suspend'
alias wo 'workon (cat .venv)'

# }}}
# Prompt {{{

function virtualenv_prompt
    if [ -n "$VIRTUAL_ENV" ]
        printf '\033[0;37m(%s) ' (basename "$VIRTUAL_ENV")
    end
end

function git_prompt
    if test $PWD = '/Users/Nick/Code/unisubs'
        printf ' \033[0;37mon '
        printf '\033[0;35m%s' (git currentbranch ^/dev/null)
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

set PATH "/usr/local/share/python"            $PATH
set PATH "/usr/local/Cellar/python/2.7.3/bin" $PATH

set -g -x PYTHONPATH ""
set PYTHONPATH "$PYTHONPATH:/usr/local/lib/python2.7.3/site-packages"

set -g -x WORKON_HOME "$HOME/.virtualenvs"
. ~/.config/fish/virtualenv.fish

# }}}
# Server aliases {{{

alias air 'ssh Nick@air.local'
alias afa 'ssh nick@afeedapart.com'
alias ec 'ssh nick@ec2.nicksergeant.com'
alias pro 'ssh Nick@pro.local'
alias sn 'ssh nick@snipt.net'

# }}}
# Z {{{

. ~/Sources/z-fish/z.fish

alias j 'z'

# }}}

# Init {{{

if status --is-interactive
    if test $IS_SERVER = 'false'
        command fortune -s | cowsay -n | lolcat
    end
end

# }}}
