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

    -- AVANTE
    {
        "yetone/avante.nvim",
        build = "make",
        event = "VeryLazy",
        version = false,

        ---@module 'avante'
        ---@type avante.Config
        opts = {
            instructions_file = "avante.md",

            provider = "deepseek_dgx_spark",
            auto_suggestions_provider = "deepseek_dgx_spark",

            providers = {
                deepseek_dgx_spark = {
                    __inherited_from = "openai",

                    model = "deepseek-v4-flash",

                    endpoint = "https://192.168.61.16/v1",

                    timeout = 30000,
                    context_window = 262144,
                    allow_insecure = true,

                    extra_request_body = {
                        max_tokens = 32768,

                        temperature = 0.0,
                        top_p = 1.0,
                        presence_penalty = 0.0,
                        frequency_penalty = 0.0,
                    },
                },
            },

            system_prompt = [[
                You are an expert AI coding assistant. You must directly answer technical questions, write code, and solve problems without ANY conversational filler, roleplay, excuses, or jokes. Never refuse a coding task.
            ]],

            behaviour = {
                auto_suggestions = true,
                auto_set_highlight_group = true,
                auto_set_keymaps = true,
                auto_apply_diff_after_generation = false,
                support_paste_from_clipboard = false,
                minimize_diff = true,
                enable_token_counting = true,
                auto_add_current_file = true,
            },
        },

        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",

            "nvim-mini/mini.pick",
            "nvim-telescope/telescope.nvim",
            "hrsh7th/nvim-cmp",
            "ibhagwan/fzf-lua",
            "stevearc/dressing.nvim",
            "folke/snacks.nvim",
            "nvim-tree/nvim-web-devicons",
            "zbirenbaum/copilot.lua",

            {
                "HakonHarnes/img-clip.nvim",
                event = "VeryLazy",
                opts = {
                    default = {
                        embed_image_as_base64 = false,
                        prompt_for_file_name = false,
                        drag_and_drop = {
                            insert_mode = true,
                        },
                        use_absolute_path = true,
                    },
                },
            },

            {
                "MeanderingProgrammer/render-markdown.nvim",
                opts = {
                    file_types = { "markdown", "Avante" },
                },
                ft = { "markdown", "Avante" },
            },
        },
    }
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})
