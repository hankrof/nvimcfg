local keymap = vim.keymap.set

vim.opt.number = true

keymap("i", "(", "()<Esc>i",          { noremap = true })
keymap("i", "[", "[]<Esc>a",          { noremap = true })
keymap("i", "\'", "\'\'<Esc>i",       { noremap = true })
keymap("i", "\"", "\"\"<Esc>i",       { noremap = true })
keymap("i", ",", ", <Esc>a",          { noremap = true })
keymap("i", "{{", "{}<Esc>i",         { noremap = true })
keymap("i", "{<CR>", "{<CR>}<Esc>ko", { noremap = true })
