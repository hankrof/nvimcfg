local keymap = vim.keymap.set
keymap("n", "<F9>", "<Esc>:Neotree toggle<CR>", { silent = true })
keymap("n", "<F8>", "<Esc>:CocCommand document.toggleInlayHint<CR>", { silent = true })
keymap("n", "q:", "<nop>")
keymap("n", "q/", "<nop>")
