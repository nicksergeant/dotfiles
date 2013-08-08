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
let g:Powerline_symbols = 'fancy'
nnoremap k gk
nnoremap j gj

" }}}
" Plugins {{{

filetype off
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

Bundle 'gmarik/vundle'
Bundle 'mileszs/ack.vim.git'
Bundle 'sjl/badwolf.git'
Bundle 'vim-scripts/fish.vim.git'
Bundle 'othree/html5.vim.git'
Bundle 'scrooloose/nerdcommenter.git'
Bundle 'scrooloose/nerdtree.git'
Bundle 'rstacruz/sparkup', {'rtp': 'vim/'}
Bundle 'scrooloose/syntastic.git'
Bundle 'tpope/vim-fugitive.git'
Bundle 'tpope/vim-surround.git'
Bundle 'kien/ctrlp.vim.git'
Bundle 'maksimr/vim-jsbeautify.git'
Bundle 'digitaltoad/vim-jade.git'
Bundle 'tpope/vim-speeddating.git'
Bundle 'Lokaltog/vim-powerline.git'
Bundle 'vim-scripts/taglist.vim.git'
Bundle 'sjl/vitality.vim.git'
Bundle 'Valloric/YouCompleteMe'
Bundle 'honza/vim-snippets'
Bundle 'SirVer/ultisnips'
Bundle 'Gist.vim'
Bundle 'WebAPI.vim'
Bundle 'django.vim'

filetype plugin indent on         " Turn on file type detection.
runtime macros/matchit.vim        " Load the matchit plugin.
set nocompatible                  " Disable vi-compatibility
set laststatus=2                  " Always show the statusline
set t_Co=256                      " Explicitly tell vim that the terminal has 256 colors
nnoremap <leader>ee :SyntasticToggleMode<cr>
let g:UltiSnipsExpandTrigger = "<D-d>"
let g:ycm_collect_identifiers_from_comments_and_strings = 1
let g:ycm_filetype_blacklist = {'mail': 1, 'python': 1}
let g:sparkupExecuteMapping = "<D-e>"

" }}}

" Ack {{{

" Use Ag instead of Ack
let g:ackprg = 'ag --nogroup --nocolor --column -Q -i'

" Ack for last search.
nnoremap <silent> <leader>A :execute "Ack! '" . substitute(substitute(substitute(@/, "\\\\<", "\\\\b", ""), "\\\\>", "\\\\b", ""), "\\\\v", "", "") . "'"<CR>
nnoremap <leader>a :Ack!<space>

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
    au BufNewFile,BufRead *.less setlocal filetype=scss
    au Filetype less,css,scss setlocal foldmethod=marker
    au Filetype less,css,scss setlocal foldmarker={,}
    au Filetype less,css,scss setlocal iskeyword+=-
    au Filetype less,css,scss setlocal colorcolumn=0

    " Make {<cr> insert a pair of brackets in such a way that the cursor is correctly
    " positioned inside of them AND the following code doesn't get unfolded.
    au BufNewFile,BufRead *.less,*.css,*.scss inoremap <buffer> {<cr> {}<left><cr><space><space><cr><esc>kcc
augroup END

" }}}
" Clear everything {{{

map <leader>c :let @/=''<CR>

" }}}
" Ctrl-P {{{

let g:ctrlp_dont_split = 'NERD_tree_2'
let g:ctrlp_jump_to_buffer = 0
let g:ctrlp_map = '<leader>,'
let g:ctrlp_working_path_mode = 0
let g:ctrlp_match_window_reversed = 1
let g:ctrlp_split_window = 0
let g:ctrlp_max_height = 20
let g:ctrlp_extensions = ['tag']

let g:ctrlp_prompt_mappings = {
\ 'PrtSelectMove("j")':   ['<down>', '<s-tab>'],
\ 'PrtSelectMove("k")':   ['<up>', '<tab>'],
\ 'PrtHistory(-1)':       ['<c-n>'],
\ 'PrtHistory(1)':        ['<c-p>'],
\ 'ToggleFocus()':        ['<c-tab>'],
\ }

nnoremap <leader>. :CtrlPTag<cr>
nnoremap <leader>/ :CtrlPBufTag<cr>

nnoremap <leader><cr> :silent !/usr/local/bin/myctags<cr>:redraw!<cr>

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
nnoremap <c-z> mzzMzvzz15<c-e>`z:Pulse<cr>

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
vnoremap <leader>G :w !snipt post_and_get_url -t \| pbcopy && pbpaste \| xargs open<CR>

augroup ft_fugitive
    au!

    au BufNewFile,BufRead .git/index setlocal nolist
augroup END

" }}}
" Gist {{{

let g:gist_open_browser_after_post = 1
let g:gist_post_private = 1

" }}}
" HTML {{{

au BufNewFile,BufRead *.html nnoremap <buffer> <leader>f Vatzf
au BufNewFile,BufRead *.html setlocal filetype=htmldjango
au BufNewFile,BufRead *.html setlocal foldmethod=manual
au BufNewFile,BufRead *.html setlocal foldmethod=manual
au BufNewFile,BufRead *.html setlocal colorcolumn=0
au FileType html,htmldjango setlocal tabstop=4
au FileType html,htmldjango setlocal shiftwidth=4
au FileType html,htmldjango setlocal softtabstop=4

" }}}
" Jade {{{

augroup ft_jade
    au!
    au BufNewFile,BufRead *.jade setlocal filetype=jade
augroup END

" }}}
" Mail {{{

augroup ft_mail
    au!

    au Filetype mail setlocal spell
augroup END
highlight SpellBad term=underline gui=undercurl guisp=Orange

" }}}
" Navigation {{{

nnoremap <leader>ev <C-w>s<C-w>j<C-w>L:e $MYVIMRC<CR>
nnoremap <leader>ef <C-w>s<C-w>j<C-w>L:e ~/.config/fish/config.fish<CR>

" }}}
" NERD Tree {{{

noremap  <F2> :NERDTreeToggle<cr>
inoremap <F2> <esc>:NERDTreeToggle<cr>

au Filetype nerdtree setlocal nolist
au Filetype nerdtree setlocal colorcolumn=0

let NERDTreeHighlightCursorline=1
let NERDTreeIgnore=['.vim$', '\~$', '.*\.pyc$', 'pip-log\.txt$', 'whoosh_index', 'xapian_index', '.*.pid', 'monitor.py', '.*-fixtures-.*.json', '.*\.o$', 'db.db']

let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1

" }}}
" Saving {{{

au FocusLost * :wa
au FocusLost,TabLeave * call feedkeys("\<C-\>\<C-n>")

" }}}
" Settings {{{

let g:badwolf_html_link_underline = 0
colorscheme badwolf
set autoindent
set autoread
set autowrite
set smartindent
set undofile
"set showcmd                       " Display incomplete commands.
"set showmode                      " Display the mode you're in.
set backspace=indent,eol,start    " Intuitive backspacing.
set hidden                        " Handle multiple buffers better.
set ignorecase                    " Case-insensitive searching.
set smartcase                     " But case-sensitive if expression contains a capital letter.
set ruler                         " Show cursor position.
set incsearch                     " Highlight matches as you type.
set hlsearch                      " Highlight matches.
set scrolloff=3                   " Show 3 lines of context around the cursor.
set title                         " Set the terminal's title
set visualbell                    " No beeping.
set nobackup                      " Don't make a backup before overwriting a file.
set nowritebackup                 " And again.
set directory=$HOME/.vim/tmp//,.  " Keep swap files in one location
set tabstop=2                     " Global tab width.
set shiftwidth=2                  " And again, related.
set expandtab                     " Use spaces instead of tabs
set softtabstop=2                 " Spaces for tab
set list                          " 
set listchars=tab:▸\ ,extends:❯,precedes:❮
set shell=/bin/bash
set splitbelow
set splitright
set guifont=Menlo_for_Powerline:h14            " Font family and font size.
set antialias                     " MacVim: smooth fonts.
set encoding=utf-8                " Use UTF-8 everywhere.
set cursorline
set synmaxcol=800                 " Don't try to highlight lines longer than 800 characters.
set lazyredraw
set fillchars=diff:⣿,vert:│
set dictionary=/usr/share/dict/words
set nowrap
set colorcolumn=80

set wildmenu                      " Enhanced command line completion.
set wildmode=list:longest         " Complete files like a shell.

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

set wildignore +=cache
set wildignore +=dist
set wildignore +=migrations
set wildignore +=node_modules
set wildignore +=static

" }}}
" Spacing toggle {{{

function! SetTabSpace2()
  set tabstop=2                     " Global tab width.
  set shiftwidth=2                  " And again, related.
  set softtabstop=2                 " Spaces for tab
endfunction

function! SetTabSpace4()
  set tabstop=4                     " Global tab width.
  set shiftwidth=4                  " And again, related.
  set softtabstop=4                 " Spaces for tab
endfunction

nnoremap <leader>2 :call SetTabSpace2()<cr>
nnoremap <leader>4 :call SetTabSpace4()<cr>

" }}}
" Swap files death {{{

set noswapfile

" }}}
" URLs {{{

function! HandleURL()
  let s:uri = matchstr(getline("."), '[a-z]*:\/\/[^ >,;]*')
  echo s:uri
  if s:uri != ""
    silent exec "!open '".s:uri."'"
  else
    echo "No URI found in line."
  endif
endfunction
nmap go :call HandleURL()<cr>

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

" Unfuck my screen
nnoremap U :syntax sync fromstart<cr>:redraw!<cr>

nnoremap <c-p> <c-i>
nmap <tab> %
vmap <tab> %
nnoremap cs/ cgn

" }}}

" JavaScript {{{

augroup ft_javascript
    au!
    au FileType javascript setlocal foldmethod=marker
    au FileType javascript setlocal foldmarker={,}
augroup END

map <leader>b :call JsBeautify()<cr>

" }}}
