" Mappings {{{ 

let mapleader = ","
let maplocalleader = "\\"

inoremap <F1> <nop>
inoremap <c-u> <esc>viwUi
inoremap <s-tab> <c-d>
inoremap jk <esc>
nnoremap <F1> <nop>
nnoremap <c-e> <c-^>
nnoremap <c-p> <c-i>
nnoremap <esc> :nohl<cr>
nnoremap <tab> %
nnoremap H ^
nnoremap K <nop>
nnoremap L g_
nnoremap N Nzv
nnoremap Vat vatV
nnoremap Vit vitVkoj
nnoremap cs/ cgn
nnoremap gi <c-]>
nnoremap gs *Nzz
nnoremap j gj
nnoremap k gk
nnoremap n nzv
nnoremap tn :tn<cr>
nnoremap tp :tp<cr>
vnoremap <c-t> :sort<cr>
vnoremap <tab> %

" }}}
" Settings {{{

syntax enable

set autoindent
set autoread
set autowrite
set backspace=indent,eol,start
set breakindent
set breakindentopt=shift:2,min:40,sbr
set colorcolumn=0
set cursorline
set directory=$HOME/.vim/tmp//,.
set encoding=utf-8
set expandtab
set fillchars=diff:⣿,vert:│
set foldlevelstart=20
set formatoptions=l
set hidden
set hlsearch
set ignorecase
set incsearch
set laststatus=2
set lazyredraw
set lbr
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
set wildignore=*.db
set wildmenu
set wildmode=list:longest

silent! set invmmta
silent! colorscheme badwolf

" }}}
" Plugins {{{

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

Plug '/usr/local/opt/fzf'
Plug 'airblade/vim-gitgutter'
Plug 'junegunn/fzf.vim'
Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'
Plug 'ludovicchabant/vim-gutentags'
Plug 'michal-h21/vim-zettel'
Plug 'mxw/vim-jsx'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'pangloss/vim-javascript'
Plug 'prettier/vim-prettier', {
  \ 'do': 'yarn install',
  \ 'branch': 'release/0.x'
  \ }
Plug 'scrooloose/nerdtree'
Plug 'sjl/badwolf'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-surround'
Plug 'vimwiki/vimwiki'
Plug 'w0rp/ale'

call plug#end()

" }}}

" Ale {{{

nnoremap ' :ALEFix<cr>
nnoremap <silent> <c-n> <Plug>(ale_next_wrap)

let g:ale_cache_executable_check_failures = 1
let g:ale_sign_column_always = 1
let g:ale_sign_warning = '>>'
let g:ale_linters = {
  \ 'html': [],
  \ 'htmldjango': [],
  \ 'javascript': ['eslint'],
  \ 'markdown': [],
  \ 'scss': [],
  \ }
let g:ale_fixers = {
  \ 'javascript': ['eslint'],
  \ 'python': ['black'],
  \ 'elixir': ['mix_format'],
  \ }

" }}}
" Buffers {{{

nnoremap <c-h> <c-w>h
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-l> <c-w>l

" }}}
" CoC {{{

nnoremap <silent> go <Plug>(coc-definition)

" }}}
" Commentary {{{

nnoremap <leader>c<space> <Plug>CommentaryLine
xnoremap <leader>c<space> <Plug>Commentary

" }}}
" Copy and paste {{{

vnoremap y "+y
nnoremap yy "+yy

" }}}
" CSS {{{

augroup ft_css
    au!
    au Filetype css,scss setlocal foldmethod=marker
    au Filetype css,scss setlocal foldmarker={,}
    au Filetype css,scss setlocal iskeyword+=-

    " Make {<cr> insert a pair of brackets in such a way that the cursor is correctly
    " positioned inside of them AND the following code doesn't get unfolded.
    au BufNewFile,BufRead *.css,*.scss inoremap <buffer> {<cr> {}<left><cr><space><space><cr><esc>kcc
augroup END

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
" Focus modes {{{

nnoremap <c-m> :Goyo<cr>
nnoremap <leader>s :Limelight!!<cr>

autocmd! User GoyoEnter Limelight
autocmd! User GoyoLeave Limelight!

" }}}
" Fugitive and Hub {{{

let g:github_enterprise_urls = ['https://git.hubteam.com']

nnoremap <leader>eg :Gblame<cr>
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

" Make :Lines prompt at the bottom like other fzf actions.
command! -bang -nargs=* Lines call fzf#vim#lines(<q-args>, {'options': '--no-reverse'}, <bang>0)

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
" JavaScript {{{

let g:jsx_ext_required = 0

augroup ft_javascript
    au!
    au FileType javascript setlocal foldmethod=marker
    au FileType javascript setlocal foldmarker={,}
augroup END

com! FormatJSON %!python -m json.tool

" }}}
" Markdown {{{

autocmd BufNewFile,BufReadPost *.md setl wrap

let g:vim_markdown_new_list_item_indent = 0

command! -bar -nargs=1 OpenURL :!open <args>

function! OpenURLUnderCursor()
    let l:uri = matchstr(getline("."), '[a-z]*:\/\/[^ >,;:()]*')
    if l:uri != ""
        exec "!clear && open " . shellescape(l:uri, 1)
    else
        echo 'No URL found in line'
    endif
endfunction

function! GoToUrlAtEndOfLine()
  let save_pos = getpos(".")
  normal! g_
  silent exec OpenURLUnderCursor()
  call setpos('.', save_pos)
endfunction

nnoremap gj :call GoToUrlAtEndOfLine()<cr>

" }}}
" NERDTree {{{

noremap  <leader>x :NERDTreeToggle<cr>
noremap  <leader>f :NERDTreeFind<cr>

au Filetype nerdtree setlocal nolist
au Filetype nerdtree setlocal colorcolumn=0

let NERDTreeHighlightCursorline=1
let NERDTreeIgnore=['.vim$', '\~$', '.*\.pyc$', 'pip-log\.txt$', 'whoosh_index', 'xapian_index', '.*.pid', 'monitor.py', '.*-fixtures-.*.json', '.*\.o$', 'db.db']

let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1

" }}}
" Prettier {{{

nnoremap ; :Prettier<cr>

let g:prettier#exec_cmd_async = 1
let g:prettier#autoformat = 0

" }}}
" Quickfix window {{{

autocmd BufReadPost quickfix nnoremap <buffer> <CR> <CR>

nnoremap <M-n> :cn<cr>
nnoremap <M-p> :cp<cr>

function! QFixToggle(forced)
    if exists("g:qfix_win") && a:forced == 0
        cclose
        unlet g:qfix_win
    else
        copen 10
        let g:qfix_win = bufnr("$")
    endif
endfunction

command! -bang -nargs=? QFixToggle call QFixToggle(<bang>0)

nnoremap <silent> <f4> :QFixToggle<cr>

" }}}
" Quick edit files {{{

nnoremap <leader>ev :vsplit $MYVIMRC<cr>
nnoremap <leader>ez :vsplit ~/Sources/dotfiles/zshrc<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>

" }}}
" Snippets {{{

inoremap <c-l> console.log()<esc>i
inoremap <c-k> console.table({})<esc>hi

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

" }}}
" VimWiki {{{

let g:vimwiki_list = [{'path': '~/Dropbox (Personal)/Notes', 'path_html': '~/Dropbox (Personal)/Notes/HTML/',
      \ 'syntax': 'markdown', 'ext': '.md'}]
let g:vimwiki_folding = 'custom'
let g:zettel_fzf_command = "rg --files --column --line-number --ignore-case --no-heading --color=always "

autocmd BufNewFile *.md :r! echo \\# %:t:r
autocmd BufNewFile *.md :norm kddo

autocmd FileType vimwiki nnoremap <buffer><leader>d :VimwikiToggleListItem<cr>
autocmd FileType vimwiki nnoremap <buffer><leader>m :VimwikiIncrementListItem<cr>

" }}}
