-- configuring options
local set=vim.opt
local cmd=vim.cmd

set.number = true
set.autoindent = true
set.tabstop = 4
set.shiftwidth = 4
set.expandtab = true
set.hlsearch = true
set.incsearch = true
set.updatetime = 150
set.list = true
set.mouse = ""
set.termguicolors = true

cmd("set colorcolumn=120")
cmd("colorscheme industry")
cmd("syntax on")
