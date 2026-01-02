local pairgroup = vim.api.nvim_create_augroup("PairGroup", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = pairgroup,
  pattern = {"c", "cpp", "haskell", "rust"},
  command = "source $HOME/.config/nvim/lua/plugins/pairs.lua",
})
