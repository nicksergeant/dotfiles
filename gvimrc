set guifont=Consolas_for_Powerline:h13            " Font family and font size.
set antialias                     " MacVim: smooth fonts.
set encoding=utf-8                " Use UTF-8 everywhere.
set guioptions-=T                 " Hide toolbar.
set guioptions-=l                 " Hide toolbar.
set guioptions-=L                 " Hide toolbar.
set guioptions-=r                 " Hide toolbar.
set guioptions-=R                 " Hide toolbar.
set lines=48 columns=162          " Window dimensions.
set cursorline

iunmenu File.Save 
inoremenu <silent> File.Save <Esc>:if expand("%") == ""<Bar>browse confirm w<Bar>else<Bar>confirm w<Bar>endif<CR>

if has("gui_macvim")
  macmenu &File.New\ Tab key=<nop>
  nnoremap <D-CR> :set invfullscreen<CR>
end

