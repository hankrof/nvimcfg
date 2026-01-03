local filetypes = {"c", "cpp", "haskell", "json", "html", "cmake", "rust", "lua"}
local pairgroup = vim.api.nvim_create_augroup("PairGroup", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = pairgroup,
  pattern = filetypes,
  command = "source $HOME/.config/nvim/lua/plugins/pairs.lua",
})

local guigroup = vim.api.nvim_create_augroup("GUIGroup", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = guigroup,
  pattern = filetypes,
  command = "Neotree filesystem reveal left",
})

vim.api.nvim_create_autocmd("TabNewEntered", {
  group = guigroup,
  command = "Neotree filesystem reveal left",
})
