" General {{{ 

execute "set <M-w>=\ew"
execute "set <M-s>=\es"
inoremap <F1> <nop>
inoremap jk <esc>
let g:jsx_ext_required = 0
let g:mustache_abbreviations = 1
let mapleader = ","
set timeoutlen=1000 ttimeoutlen=0
map <leader>c :let @/=''<cr>
nmap <tab> %
nnoremap <F1> <nop>
nnoremap <c-]> f<space>
nnoremap <c-^> <nop>
nnoremap <c-e> <c-^>
nnoremap <c-p> <c-i>
nnoremap <leader>ee :ALEToggle<cr>
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
noremap <m-s> :wa<cr>
noremap <m-w> :q<cr>
noremap H ^
noremap L g_
set mouse=a
syntax enable
vmap <c-t> :sort<cr>
vmap <tab> %

" }}}
" Plugins {{{

call plug#begin('~/.vim/plugged')

function! BuildTern(info)
  if a:info.status == 'installed' || a:info.force
    !npm install
  endif
endfunction

Plug '/usr/bin/fzf'
Plug '/usr/local/opt/fzf'
Plug 'PeterRincker/vim-argumentative'
Plug 'airblade/vim-gitgutter'
Plug 'ajh17/VimCompletesMe'
Plug 'elixir-lang/vim-elixir'
Plug 'junegunn/fzf.vim'
Plug 'kchmck/vim-coffee-script'
Plug 'lokaltog/vim-easymotion'
Plug 'marijnh/tern_for_vim', { 'do': function('BuildTern') }
Plug 'moll/vim-node'
Plug 'mustache/vim-mustache-handlebars'
Plug 'mxw/vim-jsx'
Plug 'nvie/vim-flake8'
Plug 'othree/html5.vim'
Plug 'pangloss/vim-javascript'
Plug 'sbdchd/neoformat'
Plug 'scrooloose/nerdtree'
Plug 'sjl/badwolf'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'vim-scripts/AutoComplPop'
Plug 'vim-scripts/ZoomWin'
Plug 'w0rp/ale'

call plug#end()

" }}}

" Ale {{{

let g:ale_sign_column_always = 1
let g:ale_sign_warning = '>>'
let g:ale_javascript_eslint_executable = 'eslint_d'
let g:ale_javascript_eslint_use_global = 1

" }}}
" Autocomplete {{{

inoremap cl<space> console.log()<esc>i

" }}}
" Buffers {{{

map <c-h> <c-w>h
map <c-l> <c-w>l

" }}}
" CoffeeScript {{{

autocmd BufNewFile,BufReadPost *.coffee setl foldmethod=indent

" }}}
" Colors {{{

silent! colorscheme badwolf

" }}}
" Copying and pasting {{{

imap <c-v> <c-r><c-o>+
nnoremap <c-v> c<ESC>"+p
nnoremap Y y$
vmap <c-c> "+y
vmap <c-v> c<ESC>"+p
vmap <c-x> "+c

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
" fzf and ripgrep {{{

nnoremap <c-g> :Files<cr>
nnoremap <leader>A :exec "Rg ".expand("<cword>")<cr>
nnoremap <leader>a :Rg<space>
nnoremap <leader>b :Buffers<cr>
nnoremap <leader>l :Lines<cr>
nnoremap <leader>r :History<cr>

command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --ignore-case --column --line-number --no-heading --color=always '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview('up:60%')
  \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  \   <bang>0)

" }}}
" Fugitive and Hub {{{

let g:github_enterprise_urls = ['https://git.hubteam.com']

nnoremap <leader>g :Gbrowse<cr>
vnoremap <leader>g :Gbrowse<cr>
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
set statusline=\ %f%=\ [%l/%L]\ 
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
