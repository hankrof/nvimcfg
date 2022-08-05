set nocompatible              " be iMproved, required
set rtp+=~/.config/nvim/bundle/Vundle.vim
call vundle#begin('~/.config/nvim/bundle/')
" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
" coc
Plugin 'neoclide/coc.nvim', {'branch': 'release'}
" vim files for the Bitbake tool
Plugin 'kergoth/vim-bitbake'
" Better Whitespace plugin causes all trailing whitespace characters
Plugin 'ntpeters/vim-better-whitespace'
" Gitgutter provides a git diff in vim
Plugin 'airblade/vim-gitgutter'
" file manager nnn
Plugin 'mcchrish/nnn.vim'
" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
