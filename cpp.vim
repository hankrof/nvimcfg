syntax on
set colorcolumn=120
inoremap ( ()<Esc>i
inoremap [ []<Esc>a
inoremap ' ''<Esc>i
inoremap " ""<Esc>i
inoremap , , <Esc>a
inoremap {<CR> {<CR>}<Esc>ko
inoremap {{ {}<Esc>i
inoremap <silent> <F3> <Esc><C-w><Up>:hide<Esc>a
map <silent> <F3> <Esc><C-w><Up>:hide<CR>
map <silent> <F4> :TlistToggle<CR>
map <silent> <F5> :TlistUpdate<CR>
let g:Tlist_Exit_OnlyWindow = 1
autocmd VimEnter * :TlistToggle
autocmd BufWritePost *.cpp :TlistUpdate
