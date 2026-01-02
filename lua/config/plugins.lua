-- $HOME/.config/nvim/lua/plugins.lua
return {
  -- coc.nvim (needs node; optional yarn build)
  {
    "neoclide/coc.nvim",
    branch = "release",
    event = "InsertEnter",
    -- If you install coc from source and want deps auto-installed, uncomment:
    -- build = "yarn install --frozen-lockfile",
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
}

