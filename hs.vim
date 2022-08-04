syntax on
set colorcolumn=120
inoremap ( ()<Esc>i
inoremap [ []<Esc>a
inoremap ' ''<Esc>i
inoremap " ""<Esc>i
inoremap , , <Esc>a
inoremap {<CR> {<CR>}<Esc>ko
inoremap {{ {}<Esc>i
"map <silent> <F1> :YcmDiags<CR>
"map <silent> <F2> :YcmCompleter GoTo<CR>
inoremap <silent> <F3> <Esc><C-w><Up>:hide<Esc>a
map <silent> <F3> <Esc><C-w><Up>:hide<CR>
map <silent> <F4> :TlistToggle<CR>
map <silent> <F5> :TlistUpdate<CR>
"let g:ycm_global_ycm_extra_conf = "~/.vim/.ycm_extra_c_conf.py"
let g:Tlist_Exit_OnlyWindow = 1
autocmd VimEnter * :TlistToggle
autocmd BufWritePost *.c :TlistUpdate
