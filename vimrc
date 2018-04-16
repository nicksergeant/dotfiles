" General {{{ 

au FocusLost * silent! wa
execute "set <M-s>=\es"
execute "set <M-w>=\ew"
inoremap <F1> <nop>
inoremap jk <esc>
let g:jsx_ext_required = 0
let g:mustache_abbreviations = 1
let mapleader = ","
map <leader>c :let @/=''<cr>
map <esc> :let @/=''<cr>
nmap <tab> %
nnoremap <c-f> <nop>
nnoremap <F1> <nop>
nnoremap <c-^> <nop>
nnoremap <c-e> <c-^>
nnoremap <c-p> <c-i>
nnoremap <leader>ee :ALEToggle<cr>
nnoremap N Nzv
nnoremap Vat vatV
nnoremap Vit vitVkoj
nnoremap cs/ cgn
nnoremap gi <c-]>
nnoremap gs *<c-o>
nnoremap j gj
nnoremap k gk
nnoremap n nzv
nnoremap tn :tn<cr>
nnoremap tp :tp<cr>
noremap ; :Neoformat<cr>
noremap <m-s> :wa<cr>
noremap <m-w> :q<cr>
noremap H ^
noremap L g_
syntax enable
vmap <c-t> :sort<cr>
vmap <tab> %

" }}}
" Plugins {{{

call plug#begin('~/.vim/plugged')

Plug 'PeterRincker/vim-argumentative'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'elixir-lang/vim-elixir'
Plug 'kchmck/vim-coffee-script'
Plug 'lokaltog/vim-easymotion'
Plug 'maksimr/vim-jsbeautify'
Plug 'mhinz/vim-signify'
Plug 'mileszs/ack.vim'
Plug 'moll/vim-node'
Plug 'mustache/vim-mustache-handlebars'
Plug 'mxw/vim-jsx'
Plug 'nixprime/cpsm', { 'do': 'env PY3=ON ./install.sh' }
Plug 'nvie/vim-flake8'
Plug 'othree/html5.vim'
Plug 'pangloss/vim-javascript'
Plug 'sbdchd/neoformat'
Plug 'scrooloose/nerdtree'
Plug 'sjl/badwolf'
Plug 'sk1418/QFGrep'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'vim-scripts/AutoComplPop'
Plug 'w0rp/ale'

call plug#end()

" }}}

" Ack {{{

let g:ackprg = "rg --smart-case ---vimgrep --no-heading --hidden --glob '!.git'"

" Ack for last search.
nnoremap <silent> <leader>A :execute "Ack! '" . substitute(substitute(substitute(@/, "\\\\<", "\\\\b", ""), "\\\\>", "\\\\b", ""), "\\\\v", "", "") . "'"<cr>
nnoremap <leader>a :Ack!<space>

" }}}
" Ale {{{

let g:ale_cache_executable_check_failures = 1
let g:ale_sign_column_always = 1
let g:ale_sign_warning = '>>'
let g:ale_linters = {'javascript': ['eslint']}

" }}}
" Autocomplete {{{

inoremap <c-l> console.log()<esc>i

" }}}
" Buffers {{{

map <c-h> <c-w>h
map <c-j> <c-w>j
map <c-k> <c-w>k
map <c-l> <c-w>l

" }}}
" CoffeeScript {{{

autocmd BufNewFile,BufReadPost *.coffee setl foldmethod=indent

" }}}
" Colors {{{

silent! colorscheme badwolf

" }}}
" Commentary {{{

nmap <leader>c<space> <Plug>CommentaryLine
xmap <leader>c<space> <Plug>Commentary

" }}}
" Copying and pasting {{{

imap <c-v> <c-r><c-o>+
nnoremap <c-v> c<ESC>"+p
nnoremap Y y$
vmap <c-c> "+y
vmap <c-v> c<ESC>"+p
vmap <c-x> "+c

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
" Ctrlp {{{

let g:ctrlp_dont_split = 'NERD_tree_2'
let g:ctrlp_jump_to_buffer = 0
let g:ctrlp_map = ',,'
let g:ctrlp_match_func = { 'match': 'cpsm#CtrlPMatch' }
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

nnoremap <leader>, :CtrlP<cr>
nnoremap <leader>b :CtrlPBuffer<cr>
nnoremap <leader>l :CtrlPLine<cr>
nnoremap <leader>r :CtrlPMRUFiles<cr>

" }}}
" Ctags {{{

nnoremap <leader>t :exec "!ctags --options=$HOME/.ctags ."<cr><cr>

" }}}
" EasyMotion {{{

let g:EasyMotion_do_mapping = 0
nmap s <Plug>(easymotion-overwin-f2)

" }}}
" Elixir {{{

autocmd BufNewFile,BufReadPost *.exs setl foldmethod=indent
autocmd BufNewFile,BufReadPost *.ex setl foldmethod=indent

" }}}
" Folding {{{

" Shamelessly stolen from https://github.com/sjl/dotfiles/

" Space to toggle folds.
nnoremap <Space> za
vnoremap <Space> za

" Make zO recursively open whatever top level fold we're in, no matter where the
" cursor happens to be.
nnoremap zO zCzO

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

nnoremap <leader>eg :Gblame<cr>
nnoremap <leader>ga :Gadd<cr>
nnoremap <leader>gb :Gblame<cr>
nnoremap <leader>gd :Git! diff<cr>
nnoremap <leader>gg :Gbrowse<cr>
nnoremap <leader>gs :Gstatus<cr>
vnoremap <leader>gg :Gbrowse<cr>

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
" Neoformat {{{

let g:neoformat_elixir_mixformat = {
  \ 'exe': 'mix',
  \ 'args': ['format', '-'],
  \ 'stdin': 1
  \ }

let g:neoformat_javascript_prettier = {
  \ 'exe': '/Users/nsergeant/Code/ContentEditorUI/node_modules/prettier/bin-prettier.js',
  \ 'args': ['--config /Users/nsergeant/Code/ContentEditorUI/prettier.config.js'],
  \ 'stdin': 1
  \ }

let g:neoformat_scss_prettier = {
  \ 'exe': '/Users/nsergeant/Code/ContentEditorUI/node_modules/prettier/bin-prettier.js',
  \ 'args': ['--parser css', '--single-quote'],
  \ 'stdin': 1
  \ }

let g:neoformat_enabled_elixir = ['mixformat']
let g:neoformat_enabled_javascript = ['prettier']
let g:neoformat_enabled_scss = ['prettier']

" }}}
" NERD Tree {{{

inoremap <F2> <esc>:NERDTreeToggle<cr>
noremap  <D-1> :NERDTreeToggle<cr>
noremap  <D-\> :NERDTreeToggle<cr>
noremap  <F2> :NERDTreeToggle<cr>
noremap  <leader>f :NERDTreeFind<cr>
noremap  <leader>f :NERDTreeFind<cr>

au Filetype nerdtree setlocal nolist
au Filetype nerdtree setlocal colorcolumn=0

let NERDTreeHighlightCursorline=1
let NERDTreeIgnore=['.vim$', '\~$', '.*\.pyc$', 'pip-log\.txt$', 'whoosh_index', 'xapian_index', '.*.pid', 'monitor.py', '.*-fixtures-.*.json', '.*\.o$', 'db.db']

let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1

" }}}
" QFGrep {{{

nmap <leader>d <Plug>QFGrepG

" }}}
" QuickFix {{{

nnoremap <M-n> :cn<cr>
nnoremap <M-p> :cp<cr>

" }}}
" Quick edit files {{{

nnoremap <leader>ez <c-w>s<c-w>j<c-w>L:e ~/.zshrc<cr>
nnoremap <leader>ei <c-w>s<c-w>j<c-w>L:e ~/.config/i3/config<cr>
nnoremap <leader>ev <c-w>s<c-w>j<c-w>L:e $MYVIMRC<cr>

" }}}
" Settings {{{

set autoindent
set autoread
set autowrite
set backspace=indent,eol,start
set colorcolumn=0
set cursorline
set directory=$HOME/.vim/tmp//,.
set encoding=utf-8
set expandtab
set fillchars=diff:⣿,vert:│
set foldlevelstart=20
set hidden
set hlsearch
set ignorecase
set incsearch
set laststatus=2
set lazyredraw
set linespace=1
set list
set listchars=tab:▸\ ,extends:❯,precedes:❮
set mouse=a
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
set statusline=\ %f%=\ [%l/%L]\ 
set synmaxcol=800
set t_Co=256
set tabstop=2
set timeoutlen=1000 ttimeoutlen=0
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
silent! set invmmta

" }}}
" Signify {{{

highlight DiffAdd    guibg=#1C1B1A guifg=#179923
highlight DiffChange guibg=#1C1B1A guifg=#B0B030
highlight DiffDelete guibg=#1C1B1A guifg=#B82128

let g:signify_realtime = 1
let g:signify_sign_change = '~'
let g:signify_vcs_list = [ 'git' ]

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
" Zoom {{{
" Zoom / Restore window.

function! s:ZoomToggle() abort
  if exists('t:zoomed') && t:zoomed
    execute t:zoom_winrestcmd
    let t:zoomed = 0
  else
    let t:zoom_winrestcmd = winrestcmd()
    resize
    vertical resize
    let t:zoomed = 1
  endif
endfunction
command! ZoomToggle call s:ZoomToggle()
nnoremap <silent> <c-f>o :ZoomToggle<cr>

" }}}

" Environment Specific {{{

source ~/.vimrc-env

" }}}
