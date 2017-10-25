set guioptions-=m        " Hide menubar.
set guioptions-=T        " Hide toolbar.
set guioptions-=l        " Hide toolbar.
set guioptions-=L        " Hide toolbar.
set guioptions-=r        " Hide toolbar.
set guioptions-=R        " Hide toolbar.
set lines=48 columns=162 " Window dimensions.

iunmenu File.Save 
inoremenu <silent> File.Save <Esc>:if expand("%") == ""<Bar>browse confirm w<Bar>else<Bar>confirm w<Bar>endif<CR>

if has("gui_macvim")
  macmenu &File.New\ Tab key=<nop>
  nnoremap <D-CR> :set invfullscreen<CR>
  macm File.Close key=<nop>
  nnoremap <silent> <D-w> <Esc>:close<CR>
end
