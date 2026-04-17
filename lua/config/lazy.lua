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

    -- Copilot
    {
      "zbirenbaum/copilot.lua",
      cmd = "Copilot",
      build = ":Copilot auth",
      event = "BufReadPost",
      opts = {
        suggestion = {
          enabled = not vim.g.ai_cmp,
          auto_trigger = true,
          hide_during_completion = vim.g.ai_cmp,
          keymap = {
            accept = false, -- handled by nvim-cmp / blink.cmp
            next = "<M-]>",
            prev = "<M-[>",
          },
        },
        panel = { enabled = true },
        filetypes = {
          markdown = true,
          help = true,
        },
      },
      enabled = false,
    },

    {
      "CopilotC-Nvim/CopilotChat.nvim",
        dependencies = {
          { "github/copilot.vim" }, -- or zbirenbaum/copilot.lua
          { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
        },
        build = "make tiktoken", -- Only on MacOS or Linux
        opts = {
          -- See Configuration section for options
          -- model = "gpt-3.1-turbo",
        },
        -- See Commands section for default commands if you want to lazy load on them
        enabled = false,
    },

    --AVANTE
    {
        "yetone/avante.nvim",
        -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
        -- ⚠️ must add this setting! ! !
        build = vim.fn.has("win32") ~= 0
        and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
        or "make",
        event = "VeryLazy",
        version = false, -- Never set this value to "*"! Never!
        ---@module 'avante'
        ---@type avante.Config
        opts = {
            -- add any opts here
            -- this file can contain specific instructions for your project
            instructions_file = "avante.md",
            auto_suggestions_provider = "openai",
            provider = "openai",
            providers = {
                openai = {
                    endpoint = "https://192.168.61.12/v1/",
                    model = "Gemma-4-26B-A4B-it-NVFP4A16",
                    api_key = "sk-AKcQkcH565mp0pD6Y346iw",
                    timeout = 30000, -- Timeout in milliseconds
                    extra_request_body = {
                        temperature = 0.75,
                        max_tokens = 32768,
                    },
                },
            },
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            --- The below dependencies are optional,
            "nvim-mini/mini.pick", -- for file_selector provider mini.pick
            "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
            "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
            "ibhagwan/fzf-lua", -- for file_selector provider fzf
            "stevearc/dressing.nvim", -- for input provider dressing
            "folke/snacks.nvim", -- for input provider snacks
            "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
            "zbirenbaum/copilot.lua", -- for providers='copilot'
            {
                -- support for image pasting
                "HakonHarnes/img-clip.nvim",
                event = "VeryLazy",
                opts = {
                    -- recommended settings
                    default = {
                        embed_image_as_base64 = false,
                        prompt_for_file_name = false,
                        drag_and_drop = {
                            insert_mode = true,
                        },
                        -- required for Windows users
                        use_absolute_path = true,
                    },
                },
            },
            {
                -- Make sure to set this up properly if you have lazy=true
                'MeanderingProgrammer/render-markdown.nvim',
                opts = {
                    file_types = { "markdown", "Avante" },
                },
                ft = { "markdown", "Avante" },
            },
        },
    },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})
