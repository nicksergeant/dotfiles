" General {{{ 

execute "set <M-w>=\ew"
execute "set <M-s>=\es"
inoremap <F1> <nop>
inoremap jk <esc>
let g:UltiSnipsExpandTrigger = "<D-d>"
let g:jsx_ext_required = 0
let g:mustache_abbreviations = 1
let g:sparkupExecuteMapping = "<D-e>"
let mapleader = ","
set timeoutlen=1000 ttimeoutlen=0
map <leader>c :let @/=''<CR>
nmap <tab> %
nnoremap <F1> <nop>
nnoremap <c-]> f<space>
nnoremap <c-^> <nop>
nnoremap <c-e> <c-^>
nnoremap <c-p> <c-i>
nnoremap <leader>ee :ALEToggle<cr>
nnoremap <leader>cs :let g:ctrlp_use_caching = 0<CR>
nnoremap <leader>cc :let g:ctrlp_use_caching = 1<CR>
nnoremap N Nzv
nnoremap Vat vatV
nnoremap Vit vitVkoj
nnoremap cs/ cgn
nnoremap <c-return> $hhgf
nnoremap gs *<c-o>
nnoremap j gj
nnoremap k gk
nnoremap n nzv
noremap ; :Neoformat<cr>
noremap <M-s> :wa<cr>
noremap <M-w> :q<cr>
noremap H ^
noremap L g_
set mouse=a
syntax enable
vmap <c-t> :sort<cr>
vmap <tab> %

" }}}
" Plugins {{{

filetype off
set rtp+=~/.vim/bundle/Vundle.vim/
call vundle#begin()

Plugin 'PeterRincker/vim-argumentative.git'
Plugin 'Shougo/neocomplete.vim'
Plugin 'SirVer/ultisnips.git'
Plugin 'airblade/vim-gitgutter.git'
Plugin 'ctrlpvim/ctrlp.vim.git'
Plugin 'digitaltoad/vim-pug.git'
Plugin 'elixir-lang/vim-elixir'
Plugin 'gmarik/Vundle.vim'
Plugin 'honza/vim-snippets.git'
Plugin 'kchmck/vim-coffee-script'
Plugin 'lokaltog/vim-easymotion'
Plugin 'marijnh/tern_for_vim.git'
Plugin 'mileszs/ack.vim.git'
Plugin 'moll/vim-node'
Plugin 'mustache/vim-mustache-handlebars.git'
Plugin 'mxw/vim-jsx.git'
Plugin 'nvie/vim-flake8.git'
Plugin 'othree/html5.vim.git'
Plugin 'pangloss/vim-javascript.git'
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
Plugin 'sbdchd/neoformat'
Plugin 'scrooloose/nerdtree.git'
Plugin 'sjl/badwolf.git'
Plugin 'tpope/vim-commentary.git'
Plugin 'tpope/vim-fugitive.git'
Plugin 'tpope/vim-repeat.git'
Plugin 'tpope/vim-rhubarb'
Plugin 'tpope/vim-surround.git'
Plugin 'tpope/vim-unimpaired'
Plugin 'vim-scripts/ZoomWin.git'
Plugin 'w0rp/ale'

call vundle#end()
filetype plugin indent on

" }}}

" Ack {{{

let g:ackprg = "rg --smart-case ---vimgrep --no-heading --hidden --glob '!.git'"

" Ack for last search.
nnoremap <silent> <leader>A :execute "Ack! '" . substitute(substitute(substitute(@/, "\\\\<", "\\\\b", ""), "\\\\>", "\\\\b", ""), "\\\\v", "", "") . "'"<CR>
nnoremap <leader>a :Ack!<space>

" }}}
" Ale {{{

let g:ale_sign_column_always = 1
let g:ale_sign_warning = '>>'
let g:ale_javascript_eslint_executable = 'eslint_d'
let g:ale_javascript_eslint_use_global = 1

" }}}
" Buffers {{{

map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

" }}}
" CoffeeScript {{{

autocmd BufNewFile,BufReadPost *.coffee setl foldmethod=indent

" }}}
" Colors {{{

silent! colorscheme badwolf

" }}}
" Copying and pasting {{{

imap <C-v> <C-r><C-o>+
nnoremap <C-v> c<ESC>"+p
nnoremap Y y$
vmap <C-c> "+y
vmap <C-v> c<ESC>"+p
vmap <C-x> "+c

" }}}
" Commentary {{{

nmap <leader>c<space> <Plug>CommentaryLine
xmap <leader>c<space> <Plug>Commentary

" }}}
" CSS {{{

augroup ft_css
    au!
    au BufNewFile,BufRead *.less setlocal filetype=scss
    au BufNewFile,BufRead *.css setlocal filetype=css
    au Filetype less,css,scss setlocal foldmethod=marker
    au Filetype less,css,scss setlocal foldmarker={,}
    au Filetype less,css,scss setlocal iskeyword+=-
    au Filetype less,css,scss setlocal colorcolumn=0

    " Make {<cr> insert a pair of brackets in such a way that the cursor is correctly
    " positioned inside of them AND the following code doesn't get unfolded.
    au BufNewFile,BufRead *.less,*.css,*.scss inoremap <buffer> {<cr> {}<left><cr><space><space><cr><esc>kcc
augroup END

" }}}
" Ctrl-P {{{

let g:ctrlp_dont_split = 'NERD_tree_2'
let g:ctrlp_jump_to_buffer = 0
let g:ctrlp_map = '<c-g>'
let g:ctrlp_match_window_reversed = 1
let g:ctrlp_max_height = 20
let g:ctrlp_split_window = 0
let g:ctrlp_use_caching  = 0
let g:ctrlp_user_command = "rg --files --hidden --glob '!.git' %s"
let g:ctrlp_working_path_mode = 0

let g:ctrlp_prompt_mappings = {
\ 'PrtHistory(-1)':       ['<c-n>'],
\ 'PrtHistory(1)':        ['<c-p>'],
\ 'PrtSelectMove("j")':   ['<down>', '<s-tab>'],
\ 'PrtSelectMove("k")':   ['<up>', '<tab>'],
\ 'ToggleFocus()':        ['<c-tab>'],
\ }

nnoremap <leader>/ :CtrlPBufTag<cr>

" }}}
" Elixir {{{

autocmd BufNewFile,BufReadPost *.exs setl foldmethod=indent
autocmd BufNewFile,BufReadPost *.ex setl foldmethod=indent

" }}}
" EasyMotion {{{

let g:EasyMotion_do_mapping = 0
nmap s <Plug>(easymotion-overwin-f2)

" }}}
" Folding {{{

" Shamelessly stolen from https://github.com/sjl/dotfiles/

" Space to toggle folds.
nnoremap <Space> za
vnoremap <Space> za

" Make zO recursively open whatever top level fold we're in, no matter where the
" cursor happens to be.
nnoremap zO zCzO

" "Focus" the current line.  Basically:
"
" 1. Close all folds.
" 2. Open just the folds containing the current line.
" 3. Move the line to a little bit (15 lines) above the center of the screen.
" 4. Pulse the cursor line.  My eyes are bad.
"
" This mapping wipes out the z mark, which I never use.
"
" I use :sus for the rare times I want to actually background Vim.
"nnoremap <c-z> mzzMzvzz15<c-e>`z:Pulse<cr>

function! MyFoldText() " {{{
    let line = getline(v:foldstart)

    let nucolwidth = &fdc + &number * &numberwidth
    let windowwidth = winwidth(0) - nucolwidth - 3
    let foldedlinecount = v:foldend - v:foldstart

    " expand tabs into spaces
    let onetab = strpart('          ', 0, &tabstop)
    let line = substitute(line, '\t', onetab, 'g')

    let line = strpart(line, 0, windowwidth - 2 -len(foldedlinecount))
    let fillcharcount = windowwidth - len(line) - len(foldedlinecount)
    return line . '…' . repeat(" ",fillcharcount) . foldedlinecount . '…' . ' '
endfunction " }}}
set foldtext=MyFoldText()

" }}}
" Fugitive and Hub {{{

let g:github_enterprise_urls = ['https://git.hubteam.com']

nnoremap <leader>g :Gbrowse<CR>
vnoremap <leader>g :Gbrowse<CR>
nnoremap <leader>gd :Gdiff<cr>
nnoremap <leader>gs :Gstatus<cr>
nnoremap <leader>gw :Gwrite<cr>
nnoremap <leader>ga :Gadd<cr>
nnoremap <leader>gb :Gblame<cr>
vnoremap <leader>gb :Gblame<cr>
nnoremap <leader>gco :Gcheckout<cr>
nnoremap <leader>gci :Gcommit<cr>
nnoremap <leader>gm :Gmove<cr>
nnoremap <leader>gr :Gremove<cr>
nnoremap <leader>gl :Shell git gl -18<cr>:wincmd \|<cr>

augroup ft_fugitive
    au!
    au BufNewFile,BufRead .git/index setlocal nolist
augroup END

" }}}
" HTML {{{

au BufNewFile,BufRead *.ejs setlocal filetype=html
au BufNewFile,BufRead *.app setlocal filetype=html
au BufNewFile,BufRead *.cmp setlocal filetype=html
au BufNewFile,BufRead *.html nnoremap <buffer> <leader>f Vatzf
au BufNewFile,BufRead *.html setlocal foldmethod=manual
au FileType html setlocal tabstop=2
au FileType html setlocal shiftwidth=2
au FileType html setlocal softtabstop=2

" }}}
" Jade {{{

augroup ft_jade
    au!
    au BufNewFile,BufRead *.jade setlocal filetype=pug
augroup END

" }}}
" JavaScript {{{

au BufNewFile,BufRead *.es6 setlocal filetype=javascript
au BufNewFile,BufRead *.jsx setlocal filetype=javascript

augroup ft_javascript
    au!
    au FileType javascript setlocal foldmethod=marker
    au FileType javascript setlocal foldmarker={,}
    " au BufWritePre *.js Neoformat
augroup END

com! FormatJSON %!python -m json.tool

" }}}
" Neocomplete {{{

let g:neocomplete#enable_at_startup = 1
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS

" }}}
" Neoformat {{{

let g:neoformat_elixir_exfmt = {
  \ 'exe': 'mix',
  \ 'args': ['exfmt', '--stdin'],
  \ 'stdin': 1
  \ }

let g:neoformat_javascript_prettier = {
  \ 'exe': '/Users/nsergeant/Code/ContentEditorUI/node_modules/prettier/bin/prettier.js',
  \ 'args': ['--config /Users/nsergeant/Code/ContentEditorUI/prettier.config.js'],
  \ 'stdin': 1
  \ }

let g:neoformat_scss_prettier = {
  \ 'exe': '/Users/nsergeant/Code/ContentEditorUI/node_modules/prettier/bin/prettier.js',
  \ 'args': ['--parser postcss', '--single-quote'],
  \ 'stdin': 1
  \ }

let g:neoformat_enabled_elixir = ['exfmt']
let g:neoformat_enabled_javascript = ['prettier']
let g:neoformat_enabled_scss = ['prettier']

" }}}
" NERD Tree {{{

noremap  <F2> :NERDTreeToggle<cr>
noremap  <D-1> :NERDTreeToggle<cr>
inoremap <F2> <esc>:NERDTreeToggle<cr>
noremap  <leader>f :NERDTreeFind<cr>
noremap  <leader>f :NERDTreeFind<cr>

au Filetype nerdtree setlocal nolist
au Filetype nerdtree setlocal colorcolumn=0

let NERDTreeHighlightCursorline=1
let NERDTreeIgnore=['.vim$', '\~$', '.*\.pyc$', 'pip-log\.txt$', 'whoosh_index', 'xapian_index', '.*.pid', 'monitor.py', '.*-fixtures-.*.json', '.*\.o$', 'db.db']

let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1

" }}}
" Quick edit files {{{

nnoremap <leader>ez <C-w>s<C-w>j<C-w>L:e ~/.zshrc<CR>
nnoremap <leader>ei <C-w>s<C-w>j<C-w>L:e ~/.config/i3/config<CR>
nnoremap <leader>ev <C-w>s<C-w>j<C-w>L:e $MYVIMRC<CR>

" }}}
" Settings {{{

set autoindent
set autoread
set autowrite
set backspace=indent,eol,start
set colorcolumn=0
set cursorline
set dictionary=/usr/share/dict/words
set directory=$HOME/.vim/tmp//,.
set encoding=utf-8
set expandtab
set fillchars=diff:⣿,vert:│
set hidden
set hlsearch
set ignorecase
set incsearch
set laststatus=2
set lazyredraw
set list
set listchars=tab:▸\ ,extends:❯,precedes:❮
set nobackup
set nocompatible
set noswapfile
set nowrap
set nowritebackup
set re=1
set ruler
set scrolloff=3
set shell=/bin/bash
set shiftwidth=2
set smartcase
set smartindent
set softtabstop=2
set splitbelow
set splitright
set synmaxcol=800
set t_Co=256
set tabstop=2
set title
set undofile
set visualbell
set wildignore +=*.db
set wildignore +=*.pyc
set wildignore +=*.spl
set wildignore +=*.sql
set wildignore +=*.swo
set wildignore +=*.swp
set wildignore +=*.un~
set wildignore +=.git
set wildignore +=.hg
set wildignore +=.sass-cache
set wildignore +=.svn
set wildignore +=__init__.py
set wildignore +=__pycache__
set wildignore +=_site
set wildignore +=build
set wildignore +=cache
set wildignore +=client/vendor
set wildignore +=client/vendor-manual
set wildignore +=dist
set wildignore +=migrations
set wildignore +=node_modules
set wildignore +=staticfiles
set wildignore +=tmp
set wildignore +=vendor
set wildmenu
set wildmode=list:longest

" }}}
" Vim {{{

augroup ft_vim
    au!
    au FileType vim setlocal foldmethod=marker
    au FileType help setlocal textwidth=78
    au BufWinEnter *.txt if &ft == 'help' | wincmd L | endif
augroup END
au VimResized * exe "normal! \<c-w>="

" Stay on same line
augroup line_return
    au!
    au BufReadPost *
        \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \     execute 'normal! g`"zvzz' |
        \ endif
augroup END

" Quick source mappings
vnoremap <leader>S y:execute @@<cr>
nnoremap <leader>S ^vg_y:execute @@<cr>

" }}}
" Window Toggles {{{

command! -bang -nargs=? QFixToggle call QFixToggle(<bang>0)
function! QFixToggle(forced) " {{{
    if exists("g:qfix_win") && a:forced == 0
        cclose
        unlet g:qfix_win
    else
        copen 10
        let g:qfix_win = bufnr("$")
    endif
endfunction " }}}

nmap <silent> <f4> :QFixToggle<cr>

" }}}
