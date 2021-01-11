" Author: Nick Sergeant <nick@nicksergeant.com>
" Source: https://github.com/nicksergeant/dotfiles/blob/master/vimrc
"
" Many things here are inspired by or otherwise stolen from Steve Losh
" and his vimrc, which is certainly worth checking out:
" https://hg.stevelosh.com/dotfiles/file/tip/vim/vimrc

" Setup ---------------------------------------------------------- {{{

set nocompatible
set shell=/bin/bash\ --login

" }}}
" Basic settings ------------------------------------------------- {{{

set autoread
set autowrite
set backspace=indent,eol,start
set colorcolumn=0
set encoding=utf-8
set fillchars=diff:⣿,vert:│
set hidden
set laststatus=2
set lazyredraw " AUDIT BELOW
set linespace=0
set list
set listchars=tab:▸\ ,extends:❯,precedes:❮
set mouse=a
set nobackup
set nowritebackup
set re=1
set ruler
set scrolloff=3
set splitbelow
set splitright
set statusline=\ %f%=\ [%l/%L]\ 
set synmaxcol=800
set timeoutlen=1000 ttimeoutlen=0
set title
set updatetime=100
set visualbell

silent! set invmmta

" }}}
" Backups -------------------------------------------------------- {{{

set backup
set noswapfile
set undofile

set backupdir=~/.vim/tmp/backup//
set directory=~/.vim/tmp/swap//
set undodir=~/.vim/tmp/undo//

" Make those folders automatically if they don't already exist.
if !isdirectory(expand(&undodir))
    call mkdir(expand(&undodir), "p")
endif
if !isdirectory(expand(&backupdir))
    call mkdir(expand(&backupdir), "p")
endif
if !isdirectory(expand(&directory))
    call mkdir(expand(&directory), "p")
endif

" }}}
" Tabs, spaces, wrapping, and indentation ------------------------ {{{

set autoindent
set breakindent
set breakindentopt=shift:2,min:40,sbr
set expandtab
set formatoptions=qrn1j
set lbr
set nowrap
set shiftwidth=2
set smartindent
set softtabstop=2
set tabstop=8
set textwidth=80

" }}}
" Text search ---------------------------------------------------- {{{

set hlsearch
set ignorecase
set incsearch
set smartcase

" }}}
" Global mappings ------------------------------------------------ {{{

let mapleader = ","
let maplocalleader = "\\"

inoremap <c-u> <esc>viwUi
inoremap <s-tab> <c-d>
nnoremap <c-e> <c-^>
nnoremap <c-p> <c-i>
nnoremap <esc> :nohl<cr>
nnoremap <tab> %
nnoremap H ^
nnoremap K <nop>
nnoremap L g_
nnoremap M 0
nnoremap N Nzv
nnoremap Vat vatV
nnoremap Vit vitVkoj
nnoremap cs/ cgn
nnoremap gi <c-]>
nnoremap gs *Nzz
nnoremap j gj
nnoremap k gk
nnoremap n nzv
vnoremap <c-t> :sort<cr>
vnoremap H ^
vnoremap L g_

" Use <tab> for matching things.
map <tab> %
silent! unmap [%
silent! unmap ]%

" }}}
" Plugins -------------------------------------------------------- {{{

call plug#begin('~/.vim/plugged')

Plug '/usr/local/opt/fzf'
Plug 'adelarsq/vim-matchit'
Plug 'airblade/vim-gitgutter'
Plug 'junegunn/fzf.vim'
Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'
Plug 'ludovicchabant/vim-gutentags'
Plug 'michal-h21/vim-zettel'
Plug 'mxw/vim-jsx'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'pangloss/vim-javascript'
Plug 'prettier/vim-prettier', { 'do': 'yarn install', 'branch': 'release/0.x' }
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
" Color scheme --------------------------------------------------- {{{

syntax on

set background=dark
set termguicolors

silent! colorscheme badwolf

" }}}
" Wildmenu ------------------------------------------------------- {{{

set wildmenu
set wildmode=list:longest

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

" }}}

" ----- Plugin and filetype settings -----

" Ale ------------------------------------------------------------ {{{

nnoremap ' :ALEFix<cr>
nnoremap <silent> <c-n> :ALENextWrap<cr>

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
" Buffers -------------------------------------------------------- {{{

nnoremap <c-h> <c-w>h
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-l> <c-w>l

" }}}
" CoC ------------------------------------------------------------ {{{

nnoremap <silent> go :CocAction('jumpDefinition')<cr>

" }}}
" Commentary ----------------------------------------------------- {{{

nnoremap <leader>c<space> :Commentary<cr>
vnoremap <leader>c<space> :Commentary<cr>
onoremap <leader>c<space> :Commentary<cr>

" }}}
" Copy and paste ------------------------------------------------- {{{

nnoremap yy "+yy
vnoremap y "+y

inoremap <c-v> <esc>"+pa
nnoremap <c-v> viwo<esc>i[<esc>ea]()<esc>h"+p
vnoremap <c-v> <esc>`<i[<esc>`>ea]()<esc>h"+p

" }}}
" CSS ------------------------------------------------------------ {{{

augroup filetype_css
    au!
    au FileType css,scss setlocal foldmethod=marker
    au FileType css,scss setlocal foldmarker={,}
    au FileType css,scss setlocal iskeyword+=-

    " Make {<cr> insert a pair of brackets in such a way that the cursor is correctly
    " positioned inside of them AND the following code doesn't get unfolded.
    au BufNewFile,BufRead *.css,*.scss inoremap <buffer> {<cr> {}<left><cr><space><space><cr><esc>kcc
augroup END

" }}}
" Cursorline ----------------------------------------------------- {{{
" Only show cursorline in the current window and in normal mode.

augroup cline
    au!
    au WinLeave,InsertEnter * set nocursorline
    au WinEnter,InsertLeave * set cursorline
augroup END

" }}}
" Folding -------------------------------------------------------- {{{

set foldlevelstart=0

" Space to toggle folds.
nnoremap <Space> za
vnoremap <Space> za

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
" Focus modes ---------------------------------------------------- {{{

nnoremap <leader>v :Goyo<cr>
nnoremap <leader>h :Limelight!!<cr>
nnoremap <leader>we :set wrap!<cr>

autocmd! User GoyoEnter Limelight
autocmd! User GoyoLeave Limelight!

let g:goyo_height = '100%'
let g:goyo_width = 100

" }}}
" Fugitive and Hub ----------------------------------------------- {{{

let g:github_enterprise_urls = ['https://git.hubteam.com']

nnoremap <leader>eg :Gblame<cr>
nnoremap <leader>gg :Gbrowse<cr>
vnoremap <leader>gg :Gbrowse<cr>

augroup filetype_git
    au!
    au BufNewFile,BufRead .git/index setlocal nolist
augroup END

" }}}
" fzf and ripgrep ------------------------------------------------ {{{

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
" gitgutter ------------------------------------------------------ {{{

highlight DiffAdd    guibg=#1C1B1A guifg=#179923
highlight DiffChange guibg=#1C1B1A guifg=#B0B030
highlight DiffDelete guibg=#1C1B1A guifg=#B82128

" }}}
" HTML ----------------------------------------------------------- {{{

augroup filetype_html
  au!
  au FileType html,htmldjango nnoremap <buffer> <localleader>f Vatzf
augroup END

" }}}
" JavaScript ----------------------------------------------------- {{{

let g:jsx_ext_required = 0

augroup filetype_javascript
    au!
    au FileType javascript setlocal foldmethod=marker
    au FileType javascript setlocal foldmarker={,}
augroup END

com! FormatJSON %!python -m json.tool

" }}}
" Markdown and vimwiki ------------------------------------------- {{{

let g:vim_markdown_new_list_item_indent = 0
let g:vimwiki_list = [{'path': '~/Dropbox (Personal)/Notes', 'path_html': '~/Dropbox (Personal)/Notes/HTML/',
      \ 'syntax': 'markdown', 'ext': '.md'}]
let g:vimwiki_folding = 'custom'
let g:zettel_fzf_command = "rg --files --column --line-number --ignore-case --no-heading --color=always "

function! GoToMarkdownLinkInLine()
  let line = getline(".")
  let l:uri = matchstr(line, '](')

  if l:uri != ""
    let save_pos = getpos(".")
    silent execute "normal ^/](/\<cr>"
    silent execute "VimwikiFollowLink"
    call setpos('.', save_pos)
  else
    let l:uri = matchstr(line, '[a-z]*:\/\/[^ >,;:]*')
    if l:uri != ""
        let save_pos = getpos(".")
        silent execute "!clear && open " . shellescape(l:uri, 1)
        call setpos('.', save_pos)
    else
        echo 'No URL found in line'
    endif
  endif
endfunction

nnoremap <silent> gj :call GoToMarkdownLinkInLine()<cr>

augroup filetype_markdown
    au!
    au BufNewFile *.md :r! echo \\# %:t:r
    au BufNewFile *.md :norm kddo
augroup END

augroup filetype_vimwiki
    au!
    au FileType vimwiki imap <buffer> <s-tab> <Plug>VimwikiDecreaseLvlSingleItem
    au FileType vimwiki imap <buffer> <tab> <Plug>VimwikiIncreaseLvlSingleItem
    au FileType vimwiki nnoremap <buffer> <leader>d :VimwikiToggleListItem<cr>
    au FileType vimwiki nnoremap <buffer> <leader>m :VimwikiIncrementListItem<cr>
    au FileType vimwiki setlocal conceallevel=2
    au FileType vimwiki setlocal foldmethod=marker
    au FileType vimwiki setlocal shiftwidth=6
    au FileType vimwiki vnoremap <buffer> <leader>d :VimwikiToggleListItem<cr>
augroup END

" }}}
" NERDTree ------------------------------------------------------- {{{

noremap  <leader>x :NERDTreeToggle<cr>
noremap  <leader>f :NERDTreeFind<cr>

augroup nerdtree
    au!
    au FileType nerdtree setlocal nolist
    au FileType nerdtree setlocal colorcolumn=0
augroup END

let NERDTreeHighlightCursorline=1
let NERDTreeIgnore=['.vim$', '\~$', '.*\.pyc$', 'pip-log\.txt$', 'whoosh_index', 'xapian_index', '.*.pid', 'monitor.py', '.*-fixtures-.*.json', '.*\.o$', 'db.db']

let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1

" }}}
" Prettier ------------------------------------------------------- {{{

nnoremap ; :Prettier<cr>

let g:prettier#exec_cmd_async = 1
let g:prettier#autoformat = 0

" }}}
" Quickfix window ------------------------------------------------ {{{

augroup quickfix
    au!
    au BufReadPost quickfix nnoremap <buffer> <cr> <cr>
augroup END

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
" Quick edit files ----------------------------------------------- {{{

nnoremap <leader>ev :vsplit $MYVIMRC<cr>
nnoremap <leader>ez :vsplit ~/Sources/dotfiles/zshrc<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>

" }}}
" Snippets ------------------------------------------------------- {{{

inoremap <c-l> console.log()<esc>i
inoremap <c-k> console.table({})<esc>hi

" }}}
" vimrc ---------------------------------------------------------- {{{

augroup filetype_vim
    au!
    au BufWinEnter *.txt if &ft == 'help' | wincmd L | endif
    au FileType vim nnoremap <leader>S ^vg_y:execute @@<cr>:echo 'Sourced line.'<cr>
    au FileType vim setlocal foldmethod=marker
    au FileType vim setlocal shiftwidth=4
    au FileType vim vnoremap <leader>S y:@"<CR>
    au VimResized * exe "normal! \<c-w>="
augroup END

" Stay on same line
augroup line_return
    au!
    au BufReadPost *
        \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \     execute 'normal! g`"zvzz' |
        \ endif
augroup END

" }}}
