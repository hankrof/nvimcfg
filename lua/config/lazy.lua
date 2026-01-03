-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- coc.nvim (needs node; optional yarn build)
    {
      "neoclide/coc.nvim",
      branch = "release",
      event = { "VimEnter", "BufReadPre", "BufNewFile" },
      config = function()
          require("plugins.coc")
      end,
    },

    -- Bitbake filetype support
    {
      "kergoth/vim-bitbake",
      ft = { "bitbake", "bb", "bbappend", "bbclass", "conf" }, -- safe; will still load on demand
    },

    -- Highlight / strip trailing whitespace (loads when editing files)
    {
      "ntpeters/vim-better-whitespace",
      event = { "BufReadPre", "BufNewFile" },
    },

    -- Git diff signs in the gutter
    {
      "airblade/vim-gitgutter",
      event = { "BufReadPre", "BufNewFile" },
    },

    -- Neo-tree file manager (+ dependencies)
    {
      "nvim-neo-tree/neo-tree.nvim",
      branch = "v3.x",
      cmd = { "Neotree", "NeoTreeShow", "NeoTreeFocus", "NeoTreeToggle" },
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
      },
    },

    -- PlantUML syntax
    {
      "aklt/plantuml-syntax",
      ft = { "plantuml" },
    },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})
