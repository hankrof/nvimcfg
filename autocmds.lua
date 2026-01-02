vim.api.nvim_create_augroup("C_Setting", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = "C_Setting",
  pattern = "c",
  command = "source ~/.config/nvim/c.vim",
})

vim.api.nvim_create_augroup("CPP_Setting", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = "CPP_Setting",
  pattern = "cpp",
  command = "source ~/.config/nvim/cpp.vim",
})

vim.api.nvim_create_augroup("HS_Setting", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = "HS_Setting",
  pattern = "haskell",
  command = "source ~/.config/nvim/hs.vim",
})

vim.api.nvim_create_augroup("Coc_Setting", { clear = true })
vim.cmd("source ~/.config/nvim/coc.vim")

vim.api.nvim_create_augroup("Rust_Setting", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = "Rust_Setting",
  pattern = "rust",
  command = "source ~/.config/nvim/rust.vim",
})

vim.api.nvim_create_augroup("Bitbake", { clear = true })
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  group = "Bitbake",
  pattern = "*.bb*",
  command = "set filetype=bitbake",
})

vim.api.nvim_create_augroup("Vundle_Setting", { clear = true })
vim.cmd("source ~/.config/nvim/vundle.vim")

