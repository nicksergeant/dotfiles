" Author: Nick Sergeant <nick@nicksergeant.com>
" Source: https://github.com/nicksergeant/dotfiles/blob/master/vimrc
"
" Many things here are inspired by or otherwise stolen from Steve Losh
" and his vimrc, which is certainly worth checking out:
" https://hg.stevelosh.com/dotfiles/file/tip/vim/vimrc

" ----- Vim settings -------------------------------------------------

" Setup ---------------------------------------------------------- {{{

set nocompatible
set shell=/bin/bash
filetype plugin indent on

" }}}
" Basic settings ------------------------------------------------- {{{

set autowrite
set backspace=indent,eol,start
set colorcolumn=0
set encoding=utf-8
set fillchars=diff:⣿,vert:│
set hidden
set laststatus=2
set lazyredraw
set list
set listchars=tab:▸\ ,extends:❯,precedes:❮
set mouse=a
set scrolloff=0
set splitbelow
set splitright
set statusline=%f%=%c\ @\ %l/%L\ %y
set synmaxcol=800
set title
set visualbell

" Disable netrw for nvim-tree.
lua <<EOF
vim.g.loaded = 1
vim.g.loaded_netrwPlugin = 1
EOF

" Reload file if it has changed on focus.
set autoread
autocmd FocusGained * checktime

" Save file on focus lost.
autocmd FocusLost * silent! wa

" Timeout on key codes but not mappings.
set notimeout
set ttimeout
set ttimeoutlen=10

" Make macOS's option key behave as meta (<m-...).
silent! set invmmta

" }}}
" Backups -------------------------------------------------------- {{{

set backup
set noswapfile
set undofile

set backupdir=~/.vim/tmp/backup//
set directory=~/.vim/tmp/swap//
set undodir=~/.vim/tmp/undo//

" Create those folders if they don't exist.
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
set textwidth=80

" }}}
" Text search ---------------------------------------------------- {{{

set gdefault
set hlsearch
set ignorecase
set incsearch
set smartcase

" }}}
" Global mappings ------------------------------------------------ {{{

let mapleader = ","
let maplocalleader = "\\"

inoremap <s-tab> <c-d>
nnoremap <c-e> <c-^>
nnoremap <c-h> <c-w>h
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-l> <c-w>l
nnoremap <c-p> <c-i>
nnoremap <esc> :nohl<cr>
nnoremap <leader>we :set wrap!<cr>
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
nnoremap gs *N
nnoremap j gj
nnoremap k gk
nnoremap n nzv
vnoremap <c-t> :sort i<cr>
vnoremap H ^
vnoremap L g_

" Use <tab> for matching things.
map <tab> %
silent! unmap [%
silent! unmap ]%

" }}}
" Plugins -------------------------------------------------------- {{{

call plug#begin('~/.vim/plugged')

Plug 'airblade/vim-gitgutter'
Plug 'chrisbra/matchit'
Plug 'dense-analysis/ale'
Plug 'github/copilot.vim'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/vim-vsnip-integ'
Plug 'isomoar/vim-css-to-inline'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'junegunn/vim-after-object'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'neovim/nvim-lspconfig'
Plug 'nicksergeant/badwolf'
Plug 'nicksergeant/goyo.vim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'onsails/lspkind-nvim'
Plug 'preservim/nerdtree'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-surround'

call plug#end()

" }}}
" LSP------------------------------------------------------------- {{{

lua <<EOF
require('lsp')
EOF

" }}}
" Color scheme --------------------------------------------------- {{{

syntax on
set termguicolors
set background=dark
silent! colorscheme badwolf

" }}}
" Wildmenu ------------------------------------------------------- {{{

set wildmenu
set wildmode=list:longest

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
set wildignore+=tags

" }}}

" ----- Plugin and filetype settings ---------------------------------

" Ale ------------------------------------------------------------ {{{

nnoremap ; :ALEFix<cr>
nnoremap <silent> <c-n> :ALENextWrap<cr>

let g:ale_cache_executable_check_failures = 1
let g:ale_linters_explicit = 1
let g:ale_sign_column_always = 0
let g:ale_sign_warning = '>>'
let g:ale_fix_on_save = 1
let g:ale_fixers = {
  \ 'conf': ['prettier'],
  \ 'css': ['prettier'],
  \ 'elixir': ['mix_format'],
  \ 'heex': ['mix_format'],
  \ 'html': ['prettier'],
  \ 'htmldjango': ['prettier'],
  \ 'javascript': ['prettier'],
  \ 'json': ['prettier'],
  \ 'python': ['black'],
  \ 'scss': ['prettier'],
  \ 'svelte': ['prettier'],
  \ 'typescript': ['prettier'],
  \ 'typescriptreact': ['prettier'],
  \ }
let g:ale_linters = {
  \ 'html': [],
  \ 'htmldjango': [],
  \ 'javascript': ['eslint'],
  \ 'markdown': [],
  \ 'scss': [],
  \ 'typescript': ['eslint'],
  \ 'typescriptreact': ['eslint'],
  \ }

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

    " Make {<cr> insert a pair of brackets in such a way that the
    " cursor is correctly positioned inside of them AND the following
    " code doesn't get unfolded.
    au BufNewFile,BufRead *.css,*.scss inoremap <buffer> {<cr> {}<left><cr><space><space><cr><esc>kcc
augroup END

" }}}
" Ctags ---------------------------------------------------------- {{{

let g:gutentags_ctags_executable = "/usr/local/bin/ctags"

" }}}
" Cursorline ----------------------------------------------------- {{{

" Only show cursorline in the current window and in normal mode.
augroup cline
    au!
    au WinLeave,InsertEnter * set nocursorline
    au WinEnter,InsertLeave * set cursorline
augroup END

" }}}
" Elixir ---------------------------------------------------------- {{{

lua <<EOF
require('lspconfig').elixirls.setup({
    cmd = {"/opt/homebrew/bin/elixir-ls"},
    settings = {
      elixirLS = {
        dialyzerEnabled = false,
        fetchDeps = false
      }
    }
})
EOF

" }}}
" Emmet ---------------------------------------------------------- {{{

lua <<EOF
require('lspconfig').emmet_ls.setup({
    filetypes = {
        'css',
        'heex',
        'html',
        'htmldjango',
        'javascript',
        'javascriptreact',
        'sass',
        'scss',
        'typescript',
        'typescriptreact',
    },
    init_options = {
      html = {
        options = {
          -- For possible options, see: https://github.com/emmetio/emmet/blob/master/src/config.ts#L79-L267
          ["bem.enabled"] = true,
        },
      },
    }
})
EOF

" }}}
" Folding -------------------------------------------------------- {{{

set foldlevelstart=99

" Space to toggle folds.
nnoremap <space> za
vnoremap <space> za

" Make zO recursively open whatever fold we're in, even if it's partially open.
nnoremap zO zczO

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
nnoremap f zMzczO`

function! MyFoldText()
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
endfunction

set foldtext=MyFoldText()

" }}}
" Focus ---------------------------------------------------------- {{{

nnoremap <leader>v :Goyo<cr>

let g:goyo_height = '100%'
let g:goyo_width = 125

function! s:goyo_enter()
  if executable('tmux') && strlen($TMUX)
    silent !tmux set status off
    silent !tmux list-panes -F '\#F' | grep -q Z || tmux resize-pane -Z
  endif
  GitGutterEnable
endfunction

function! s:goyo_leave()
  if executable('tmux') && strlen($TMUX)
    silent !tmux set status on
    silent !tmux list-panes -F '\#F' | grep -q Z && tmux resize-pane -Z
  endif
  GitGutterEnable
endfunction

autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()

" }}}
" Fzf ------------------------------------------------------------ {{{

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

command! -nargs=* Rg call fzf#run({
  \ 'source':  printf('rg --ignore-case --column --line-number --no-heading -g "!tags" "%s"',
  \                   escape(empty(<q-args>) ? '^(?=.)' : <q-args>, '"\')),
  \ 'sink*':    function('<sid>rg_handler'),
  \ 'options': '--ansi --expect=ctrl-t,ctrl-v,ctrl-x '.
  \            '--multi --bind=ctrl-a:select-all,ctrl-d:deselect-all '.
  \            '--color hl:68,hl+:110',
  \ 'down':    '50%'
  \ })

command! -nargs=0 FuzzyFile call fzf#run({
  \ 'source': 'rg --files --no-heading -g "!tags" ',
  \ 'sink*': function('<sid>files_handler'),
  \ 'options': '--ansi --expect=ctrl-t,ctrl-v,ctrl-x '.
  \            '--multi --bind=ctrl-a:select-all,ctrl-d:deselect-all '.
  \            '--color hl:68,hl+:110',
  \ 'down': '50%'
  \ })

" }}}
" Git ------------------------------------------------------------ {{{

let g:github_enterprise_urls = ['https://git.hubteam.com']

" Dark mode only
highlight DiffAdd    guibg=#1c1c1c guifg=#179923
highlight DiffChange guibg=#1c1c1c guifg=#B0B030
highlight DiffDelete guibg=#1c1c1c guifg=#B82128

nnoremap <leader>eg :Git blame<cr>
nnoremap <leader>gg :GBrowse<cr>
vnoremap <leader>gg :GBrowse<cr>

augroup filetype_git
    au!
    au BufNewFile,BufRead .git/index setlocal nolist
augroup END

" }}}
" HTML ----------------------------------------------------------- {{{

augroup filetype_html
  au!
  au FileType html,htmldjango,heex inoremap <buffer> <c-l> class=""<esc>i
  au FileType html,htmldjango nnoremap <buffer> <localleader>f Vatzf
augroup END

" }}}
" JavaScript ----------------------------------------------------- {{{

let g:jsx_ext_required = 0

augroup filetype_typescriptreact
    au!
    au FileType typescriptreact inoremap <buffer> <c-k> console.table({})<esc>hi
    au FileType typescriptreact inoremap <buffer> <c-l> console.log()<esc>i
    au FileType typescriptreact setlocal foldmarker={,}
    au FileType typescriptreact setlocal foldmethod=marker
augroup END

augroup filetype_typescript
    au!
    au FileType typescript inoremap <buffer> <c-k> console.table({})<esc>hi
    au FileType typescript inoremap <buffer> <c-l> console.log()<esc>i
    au FileType typescript setlocal foldmarker={,}
    au FileType typescript setlocal foldmethod=marker
augroup END

augroup filetype_javascript
    au!
    au FileType javascript inoremap <buffer> <c-k> console.table({})<esc>hi
    au FileType javascript inoremap <buffer> <c-l> console.log()<esc>i
    au FileType javascript setlocal foldmarker={,}
    au FileType javascript setlocal foldmethod=marker
augroup END

" }}}
" LSP and Autocomplete ------------------------------------------- {{{

let g:diagnosticsEnabled = 1

function! ToggleDiagnostics()
    if g:diagnosticsEnabled
        call ale#toggle#Disable()
        lua vim.diagnostic.disable()
        let g:diagnosticsEnabled = 0
    else
        call ale#toggle#Enable()
        lua vim.diagnostic.enable()
        let g:diagnosticsEnabled = 1
    endif
endfunction

nnoremap <leader>d :call ToggleDiagnostics()<cr>

set completeopt=menu,menuone,noselect

lua <<EOF
local cmp = require'cmp'
local types = require('cmp.types')

vim.keymap.set('n', '<c-m>', vim.diagnostic.open_float, opts)

cmp.setup({
snippet = {
  expand = function(args)
    vim.fn["vsnip#anonymous"](args.body)
  end,
},
mapping = {
  ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
  ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
  ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
  ['<C-y>'] = cmp.config.disable, -- If you want to remove the default `<C-y>` mapping, You can specify `cmp.config.disable` value.
  ['<C-e>'] = cmp.mapping({
    i = cmp.mapping.abort(),
    c = cmp.mapping.close(),
  }),
  ['<CR>'] = cmp.mapping.confirm({ select = true }),
  ['<Down>'] = cmp.mapping({
    i = cmp.mapping.select_next_item({ behavior = types.cmp.SelectBehavior.Select }),
    c = function(fallback)
      local cmp = require('cmp')
      cmp.close()
      vim.schedule(cmp.suspend())
      fallback()
    end,
  }),
  ['<Up>'] = cmp.mapping({
    i = cmp.mapping.select_prev_item({ behavior = types.cmp.SelectBehavior.Select }),
    c = function(fallback)
      local cmp = require('cmp')
      cmp.close()
      vim.schedule(cmp.suspend())
      fallback()
    end,
  })
},
sources = cmp.config.sources({
  { name = 'nvim_lsp' },
  { name = 'vsnip' },
}, {
  { name = 'buffer' },
})
})
cmp.setup.cmdline('/', {
sources = {
  { name = 'buffer' }
}
})
cmp.setup.cmdline(':', {
sources = cmp.config.sources({
  { name = 'path' }
}, {
  { name = 'cmdline' }
})
})
EOF

" }}}
" Miscellaneous -------------------------------------------------- {{{

autocmd VimEnter * call after_object#enable('=', ':', '-', '#', ' ')

" }}}
" NERDtree ------------------------------------------------------ {{{

noremap  <leader>f :NERDTreeFind<cr>

augroup nerdtree
    au!
    au FileType nerdtree setlocal nolist
augroup END

let NERDTreeDirArrows = 1
let NERDTreeHighlightCursorline = 1
let NERDTreeMinimalUI = 1
let NERDTreeMinimalMenu=1
" let NERDTreeWinSize=60

" }}}
" Python --------------------------------------------------- {{{

lua <<EOF
require('lspconfig').pyright.setup{}
EOF

" }}}
" Quickfix window ------------------------------------------------ {{{

augroup quickfix
    au!
    au BufReadPost quickfix nnoremap <buffer> <cr> <cr>
augroup END

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

nnoremap <m-n> :cn<cr>
nnoremap <m-p> :cp<cr>

" }}}
" Source files --------------------------------------------------- {{{

nnoremap <leader>ev :vsplit $MYVIMRC<cr>
nnoremap <leader>ez :vsplit ~/Sources/dotfiles/zshrc<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>

" }}}
" Treesitter ----------------------------------------------------- {{{

lua <<EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = "all",
  highlight = { enable = true, disable = { "markdown" } },
  ignore_install = { "haskell", "phpdoc" }
}
EOF

" }}}
" Vimrc ---------------------------------------------------------- {{{

augroup filetype_vim
    au!
    au BufWinEnter *.txt if &ft == 'help' | wincmd L | endif
    au FileType vim nnoremap <leader>S ^vg_y:execute @@<cr>:echo 'Sourced line.'<cr>
    au FileType vim setlocal foldmethod=marker
    au FileType vim setlocal shiftwidth=4
    au FileType vim vnoremap <leader>S y:@"<CR>
    au VimResized * exe "normal! \<c-w>="
augroup END

" Make sure Vim returns to the same line when you reopen a file.
" Thanks, Steve and Amit!
augroup line_return
    au!
    au BufReadPost *
        \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \     execute 'normal! g`"zvzz' |
        \ endif
augroup END

" }}}
" Zshrc ---------------------------------------------------------- {{{

augroup filetype_zsh
    au!
    au FileType zsh setlocal foldmethod=marker
augroup END

" }}}

" Imports -------------------------------------------------------- {{{

source ~/.env-vimrc

" }}}
