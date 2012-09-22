" Basic {{{ 

set nocompatible
syntax enable
let mapleader = ","

inoremap jk <ESC>
nnoremap Y y$
nnoremap n nzv
nnoremap N Nzv
nnoremap * *<c-o>
nnoremap gs <c-]>
nnoremap <c-e> <c-^>
nnoremap <c-^> <nop>
noremap H ^
noremap L g_
nnoremap Vit vitVkoj
nnoremap Vat vatV

" }}}

" Ack {{{

" Use Ag instead of Ack
let g:ackprg = 'ag --nogroup --nocolor --column'

" Ack for last search.
nnoremap <silent> <leader>A :execute "Ack! -i '" . substitute(substitute(substitute(@/, "\\\\<", "\\\\b", ""), "\\\\>", "\\\\b", ""), "\\\\v", "", "") . "'"<CR>
nnoremap <leader>a :Ack! -i<space>

" }}}
" Buffers {{{

map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

" }}}
" CSS {{{

augroup ft_css
    au!
    au BufNewFile,BufRead *.less setlocal filetype=less
    au Filetype less,css,scss setlocal foldmethod=marker
    au Filetype less,css,scss setlocal foldmarker={,}
    au Filetype less,css,scss setlocal iskeyword+=-

    " Make {<cr> insert a pair of brackets in such a way that the cursor is correctly
    " positioned inside of them AND the following code doesn't get unfolded.
    au BufNewFile,BufRead *.less,*.css,*.scss inoremap <buffer> {<cr> {}<left><cr><space><space><space><space>.<cr><esc>kA<bs>
augroup END

" }}}
" Clear everything {{{

map <leader>c :let @/=''<CR>

" }}}
" Disable keys {{{

map <up> <nop>
map <down> <nop>
map <left> <nop>
map <right> <nop>
inoremap <F1> <nop>
nnoremap <F1> <nop>

" }}}
" Error Toggles {{{

command! ErrorsToggle call ErrorsToggle()
function! ErrorsToggle() " {{{
    if exists("w:is_error_window")
        unlet w:is_error_window
        exec "q"
    else
        exec "Errors"
        lopen
        let w:is_error_window = 1
    endif
endfunction " }}}

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

nmap <silent> <f3> :ErrorsToggle<cr>
nmap <silent> <f4> :QFixToggle<cr>

" }}}
" Fish {{{

augroup ft_fish
    au!
    au BufNewFile,BufRead *.fish setlocal filetype=fish
    au FileType fish setlocal foldmethod=marker foldmarker={{{,}}}
augroup END

" }}}
" Folding {{{

nnoremap zO zCzO
nnoremap <Space> za
vnoremap <Space> za

" }}}
" Git and Pastebin {{{

vnoremap <leader>g :Gbrowse<CR>
vnoremap <leader>G :w !snipt post_and_get_url \| pbcopy && pbpaste \| xargs open<CR>

" }}}
" HTML {{{

au BufNewFile,BufRead *.html nnoremap <buffer> <leader>f Vatzf
au BufNewFile,BufRead *.html setlocal filetype=htmldjango
au BufNewFile,BufRead *.html setlocal foldmethod=manual
let g:user_zen_leader_key = '<D-e>'

" }}}
" JavaScript {{{

augroup ft_javascript
    au!
    au FileType javascript setlocal foldmethod=marker
    au FileType javascript setlocal foldmarker={,}
augroup END

" }}}
" {{{ Navigation

nnoremap <leader>ev <C-w>s<C-w>j<C-w>L:e $MYVIMRC<CR>
nnoremap <leader>ef <C-w>s<C-w>j<C-w>L:e ~/.config/fish/config.fish<CR>

" }}}
" NERD Tree {{{

noremap  <F2> :NERDTreeToggle<cr>
inoremap <F2> <esc>:NERDTreeToggle<cr>

au Filetype nerdtree setlocal nolist

let NERDTreeHighlightCursorline=1
let NERDTreeIgnore=['.vim$', '\~$', '.*\.pyc$', 'pip-log\.txt$', 'whoosh_index', 'xapian_index', '.*.pid', 'monitor.py', '.*-fixtures-.*.json', '.*\.o$', 'db.db']

let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1

" }}}
" Plugins {{{

call pathogen#runtime_append_all_bundles() 
runtime macros/matchit.vim        " Load the matchit plugin.
filetype plugin indent on         " Turn on file type detection.
set nocompatible                  " Disable vi-compatibility
set laststatus=2                  " Always show the statusline
let g:Powerline_symbols = 'fancy'
set t_Co=256                      " Explicitly tell vim that the terminal has 256 colors

" }}}
" {{{ Saving

au FocusLost * :wa
au FocusLost,TabLeave * call feedkeys("\<C-\>\<C-n>")

" }}}
" Settings {{{

let g:badwolf_html_link_underline = 0
colorscheme badwolf
set autoindent
set autoread
set smartindent
set gdefault
set undofile
set showcmd                       " Display incomplete commands.
set showmode                      " Display the mode you're in.
set backspace=indent,eol,start    " Intuitive backspacing.
set hidden                        " Handle multiple buffers better.
set ignorecase                    " Case-insensitive searching.
set smartcase                     " But case-sensitive if expression contains a capital letter.
set ruler                         " Show cursor position.
set incsearch                     " Highlight matches as you type.
set hlsearch                      " Highlight matches.
set wrap                          " Turn on line wrapping.
set scrolloff=3                   " Show 3 lines of context around the cursor.
set title                         " Set the terminal's title
set visualbell                    " No beeping.
set nobackup                      " Don't make a backup before overwriting a file.
set nowritebackup                 " And again.
set directory=$HOME/.vim/tmp//,.  " Keep swap files in one location
set tabstop=4                     " Global tab width.
set shiftwidth=4                  " And again, related.
set expandtab                     " Use spaces instead of tabs
set softtabstop=4                 " Spaces for tab
set wildmenu                      " Enhanced command line completion.
set wildmode=list:longest         " Complete files like a shell.
set list                          " 
set listchars=tab:▸\ ,extends:❯,precedes:❮
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*.pyc,*.un~,*/migrations/*,*.swo,*.swp,*.sql,*.db,*/cache/*,*/.sass-cache/*
set wildignore+=*/.sass-cache/*
set shell=/bin/bash

" }}}
" Swap files death {{{

set noswapfile

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

nnoremap <c-p> <c-i>
nmap <tab> %
vmap <tab> %

" }}}