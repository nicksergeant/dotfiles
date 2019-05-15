" General {{{ 

inoremap <F1> <nop>
inoremap jk <esc>
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum" " Fix colors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum" " Fix colors
let g:jsx_ext_required = 0
let g:mustache_abbreviations = 1
let mapleader = ","
map <leader>c :let @/=''<cr>
nmap m %
nnoremap <c-f> <nop>
nnoremap <F1> <nop>
nnoremap <c-^> <nop>
nnoremap <c-e> <c-^>
nnoremap N Nzv
nnoremap Vat vatV
nnoremap Vit vitVkoj
nnoremap cs/ cgn
nnoremap gt <c-]>
nnoremap gs *<c-o>zz
nnoremap j gj
nnoremap k gk
nnoremap n nzv
nnoremap tn :tn<cr>
nnoremap tp :tp<cr>
noremap ; :Prettier<cr>
noremap H ^
noremap L g_
syntax enable
vmap <c-t> :sort<cr>
vmap <tab> %

" }}}
" Plugins {{{

call plug#begin('~/.vim/plugged')

Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'
Plug 'ludovicchabant/vim-gutentags'
Plug 'mileszs/ack.vim'
Plug 'mxw/vim-jsx'
Plug 'neoclide/coc.nvim', {'tag': '*', 'do': './install.sh'}
Plug 'nicksergeant/badwolf'
Plug 'pangloss/vim-javascript'
Plug 'prettier/vim-prettier'
Plug 'scrooloose/nerdtree'
Plug 'shumphrey/fugitive-gitlab.vim'
Plug 'sk1418/QFGrep'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-surround'

call plug#end()

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
set linespace=0
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
set tabstop=2
set termguicolors
set timeoutlen=1000 ttimeoutlen=0
set title
set undofile
set updatetime=100
set visualbell
set wildignore=*.db
set wildignore+=*.git/**
set wildignore+=*.hg*
set wildignore+=*.jquery*.js
set wildignore+=*.meteor
set wildignore+=*.pyc
set wildignore+=*.sass-cache
set wildignore+=*.spl
set wildignore+=*.sql
set wildignore+=*.svn
set wildignore+=*.swo
set wildignore+=*.swp
set wildignore+=*.un~
set wildignore+=*build/**
set wildignore+=*cache/**
set wildignore+=*client/vendor-manual/**
set wildignore+=*client/vendor/**
set wildignore+=*dist/**
set wildignore+=*migrations/**
set wildignore+=*node_modules/**
set wildignore+=*package-lock.json
set wildignore+=*public/dist/**
set wildignore+=*staticfiles/**
set wildignore+=*tmp/**
set wildignore+=*vendor/**
set wildignore+=__init__.py
set wildignore+=__pycache__
set wildignore+=_site
set wildmenu
set wildmode=list:longest
silent! set invmmta

" }}}

" Prettier {{{

let g:prettier#exec_cmd_async = 1
let g:prettier#autoformat = 0

" }}}
" Autocomplete {{{

inoremap <c-l> console.log()<esc>i
inoremap <c-k> console.table({})<esc>hi

" }}}
" Buffers {{{

map <c-h> <c-w>h
map <c-j> <c-w>j
map <c-k> <c-w>k
map <c-l> <c-w>l

" }}}
" CoC {{{

nmap <silent> go <Plug>(coc-definition)

"" use <tab> for trigger completion and navigate to next complete item
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"<Paste>
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" }}}
" Colors {{{

silent! colorscheme badwolf

" }}}
" Commentary {{{

nmap <leader>c<space> <Plug>CommentaryLine
xmap <leader>c<space> <Plug>Commentary

" }}
" Copying and pasting {{{

vnoremap y "+y

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
" Focus {{{

nnoremap <leader>v <c-w>v <c-w>v :e /tmp/null<cr><esc><c-w>h <c-w>h :e /tmp/null<cr><esc><c-w>l

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
" fzf and ripgrep {{{

nnoremap <leader>, :FuzzyFile<cr>
nnoremap <leader>A :exec "Rg ".expand("<cword>")<cr>
nnoremap <leader>a :Rg<space>
nnoremap <leader>b :Buffers<cr>
nnoremap <leader>l :Lines<cr>
nnoremap <leader>r :History<cr>

function! s:rg_to_qf(line)
  let parts = split(a:line, ':')
  return {'filename': parts[0], 'lnum': parts[1], 'col': parts[2],
        \ 'text': join(parts[3:], ':')}
endfunction

function! s:filename_to_qf(f)
  return {'filename': a:f}
endfunction

function! s:rg_handler(lines)
  if len(a:lines) < 2 | return | endif

  let cmd = get({'ctrl-x': 'split',
               \ 'ctrl-v': 'vertical split',
               \ 'ctrl-t': 'tabe'}, a:lines[0], 'e')
  let list = map(a:lines[1:], 's:rg_to_qf(v:val)')

  let first = list[0]
  execute cmd escape(first.filename, ' %#\')
  execute first.lnum
  execute 'normal!' first.col.'|zz'

  if len(list) > 1
    call setqflist(list)
    copen
    wincmd p
  endif
endfunction

function! s:files_handler(lines)
  if len(a:lines) < 2 | return | endif
  let cmd = get({'ctrl-x': 'split',
               \ 'ctrl-v': 'vertical split',
               \ 'ctrl-t': 'tabe'}, a:lines[0], 'e')

  execute cmd escape(a:lines[1], ' %#\')

  let list = map(a:lines[1:], 's:filename_to_qf(v:val)')

  if len(list) > 1
    call setqflist(list)
    copen
    wincmd p
  endif
endfunction

command! -nargs=* Rg call fzf#run({
  \ 'source':  printf('rg --ignore-case --column --line-number --no-heading --color=always "%s"',
  \                   escape(empty(<q-args>) ? '^(?=.)' : <q-args>, '"\')),
  \ 'sink*':    function('<sid>rg_handler'),
  \ 'options': '--ansi --expect=ctrl-t,ctrl-v,ctrl-x '.
  \            '--multi --bind=ctrl-a:select-all,ctrl-d:deselect-all '.
  \            '--color hl:68,hl+:110',
  \ 'down':    '50%'
  \ })

command! -nargs=0 FuzzyFile call fzf#run({
  \ 'source': 'rg --files --no-heading ',
  \ 'sink*': function('<sid>files_handler'),
  \ 'options': '--ansi --expect=ctrl-t,ctrl-v,ctrl-x '.
  \            '--multi --bind=ctrl-a:select-all,ctrl-d:deselect-all '.
  \            '--color hl:68,hl+:110',
  \ 'down': '50%'
  \ })

let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }

" }}}
" Gitgutter {{{

highlight GitGutterAdd    guifg=#88dd00 ctermfg=2
highlight GitGutterChange guifg=#d78602 ctermfg=172
highlight GitGutterDelete guifg=#ea4040 ctermfg=1

" }}}
" HTML {{{

au BufNewFile,BufRead *.ejs setlocal filetype=html
au BufNewFile,BufRead *.app setlocal filetype=html
au BufNewFile,BufRead *.cmp setlocal filetype=html
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
augroup END

com! FormatJSON %!python -m json.tool

" }}}
" NERD Tree {{{

noremap  <leader>x :NERDTreeToggle<cr>
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

nnoremap <c-n> :cn<cr>
nnoremap <c-p> :cp<cr>

" }}}
" Quick edit files {{{

nnoremap <leader>ez <c-w>s<c-w>j<c-w>L:e ~/.zshrc<cr>
nnoremap <leader>ev <c-w>s<c-w>j<c-w>L:e ~/.vimrc<cr>

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
function! QFixToggle(forced)
    if exists("g:qfix_win") && a:forced == 0
        cclose
        unlet g:qfix_win
    else
        copen 10
        let g:qfix_win = bufnr("$")
    endif
endfunction

nmap <silent> <f4> :QFixToggle<cr>

" }}}
