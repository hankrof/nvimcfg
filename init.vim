set nu
set ai
set tabstop=4
set shiftwidth=4
set expandtab
set hlsearch
set incsearch
set ut=150
set list
set listchars=tab:ᐅ\ ,eol:¬
nnoremap q: <nop>
nnoremap q/ <nop>
filetype on
syntax on

augroup C_Setting
    autocmd FileType c source ~/.config/nvim/c.vim
augroup END

augroup CPP_Setting
    autocmd FileType cpp source ~/.config/nvim/cpp.vim
augroup END

augroup HS_Setting
    autocmd FileType haskell source ~/.config/nvim/hs.vim
augroup END

augroup Coc_Setting
    source ~/.config/nvim/coc.vim
augroup END

augroup Bitbake
    autocmd BufNewFile,BufRead *.bb* set filetype=bitbake
augroup END

augroup Vundle_Setting
    source ~/.config/nvim/vundle.vim
augroup END
