set guioptions-=m        " Hide menubar.
set guioptions-=T        " Hide toolbar.
set guioptions-=l        " Hide toolbar.
set guioptions-=L        " Hide toolbar.
set guioptions-=r        " Hide toolbar.
set guioptions-=R        " Hide toolbar.
set guifont=Menlo:h17
set lines=48 columns=162 " Window dimensions.

iunmenu File.Save 
inoremenu <silent> File.Save <Esc>:if expand("%") == ""<Bar>browse confirm w<Bar>else<Bar>confirm w<Bar>endif<CR>

if has("gui_macvim")
  au FocusLost * silent! :wa
  macm File.Close key=<nop>
  macmenu &File.New\ Tab key=<nop>
  map <esc> :let @/=''<cr>
  nnoremap <d-cr> :set invfullscreen<cr>
  nnoremap <silent> <d-w> <Esc>:quit<cr>
  noremap <d-s> :wa<cr>
end
