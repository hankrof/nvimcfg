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
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("lazy").setup({
  spec = {
    {
      "neoclide/coc.nvim",
      branch = "release",
      event = { "VimEnter", "BufReadPre", "BufNewFile" },
      dependencies = {
        { "junegunn/fzf", build = "./install --bin" },
        "junegunn/fzf.vim",
        { "antoinemadec/coc-fzf", branch = "release" },
      },
      config = function()
          require("plugins.coc")
      end,
    },

    {
      "kergoth/vim-bitbake",
      ft = { "bitbake", "bb", "bbappend", "bbclass", "conf" },
    },

    {
      "ntpeters/vim-better-whitespace",
      event = { "BufReadPre", "BufNewFile" },
    },

    {
      "airblade/vim-gitgutter",
      event = { "BufReadPre", "BufNewFile" },
    },

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

    {
      "aklt/plantuml-syntax",
      ft = { "plantuml" },
    },

    {
      "zbirenbaum/copilot.lua",
      cmd = "Copilot",
      event = { "InsertEnter", "BufReadPost" },

      config = function(_, opts)
        require("copilot").setup(opts)
      end,

      opts = {
        server_opts_overrides = {
          settings = {
            ["github"] = {
              endpoint = "https://api.githubcopilot.com",
            },
          },
        },

        suggestion = {
          enabled = true,
          auto_trigger = true,
          debounce = 75,
          hide_during_completion = false,
          keymap = {
            accept = "<C-L>",
            accept_word = false,
            accept_line = false,
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>",
          },
        },
        panel = {
          enabled = true,
          auto_refresh = true,
          keymap = {
            jump_prev = "[[",
            jump_next = "]]",
            accept = "<CR>",
            refresh = "gr",
            open = "<M-CR>",
          },
        },
        filetypes = {
          markdown = true,
          help = true,
          gitcommit = true,
          yaml = true,
          ["*"] = true,
        },
      },
      enabled = true,
    },

    {
      "CopilotC-Nvim/CopilotChat.nvim",
        dependencies = {
          { "zbirenbaum/copilot.lua" },
          { "nvim-lua/plenary.nvim", branch = "master" },
        },
        build = "make tiktoken",
        opts = {
        },
        enabled = false,
    },

    {
        "yetone/avante.nvim",
        branch = "main",

        build = "make",
        event = "VeryLazy",
        version = false,

        ---@module 'avante'
        ---@type avante.Config
        opts = {
            instructions_file = "avante.md",

            mode = "agentic",

            system_prompt = function()
                if require("avante.config").provider == "GLM-5.3-Flash-NVFP4" then
                    return [[
You are GLM-5.3-Flash, served locally through vLLM and LiteLLM.
Always respond in Traditional Chinese unless another language is requested.

Think deeply before acting. Prioritize correctness and root-cause analysis over speed.

For coding tasks:
- Inspect only the context needed to understand the problem.
- Identify the root cause before making changes.
- Make the smallest sufficient change that solves the requested problem.
- Preserve existing behavior, interfaces, architecture, and style unless a change is required.
- Do not modify unrelated files.
- Do not perform unsolicited refactoring, cleanup, dependency upgrades, formatting, documentation, or feature additions.
- Do not create extra files, scripts, tests, or abstractions unless they are necessary for the requested task.
- Do not fix adjacent issues unless they block the requested task.
- Do not repeat equivalent reads, searches, or commands unless new information justifies it.
- Use tools only when they reduce uncertainty or are required to complete or verify the task.
- For simple tasks, avoid unnecessary exploration and testing.
- For complex tasks, investigate enough to understand dependencies before editing.
- If ambiguity could materially change the implementation, ask a concise question instead of guessing.
- Verify the result with the smallest relevant check or test.
- Do not run broad test suites when a focused test is sufficient.
- Once the requested problem is solved and verified, stop.
Keep the final response concise.
State what changed, how it was verified, and any remaining issue.
Do not narrate routine tool usage.
Do not expose hidden reasoning or chain-of-thought.
]]
                end
                if require("avante.config").provider == "Qwen3.8-27B-NVFP4" then
                    return [[
Prioritize correctness and root-cause analysis over speed.

Investigation:
- Inspect only the context needed to understand the task.
- Identify the root cause before making changes.
- Do not repeat equivalent reads, searches, or commands unless new information justifies it.
- Use tools only when they reduce uncertainty or are required to complete or verify the task.
- For simple tasks, avoid unnecessary exploration.
- For complex tasks, investigate enough to understand dependencies before editing.
- If ambiguity could materially change the implementation, ask a concise question instead of guessing.

Changes:
- Make the smallest sufficient change that solves the requested problem.
- Preserve existing behavior, interfaces, architecture, and style unless a change is required.
- Do not modify unrelated files.
- Do not perform unsolicited refactoring, cleanup, dependency upgrades, formatting, documentation, or feature additions.
- Do not create extra files, scripts, tests, or abstractions unless necessary.
- Do not fix adjacent issues unless they block the requested task.

Verification:
- Verify with the smallest relevant check or test.
- Do not run broad test suites when a focused test is sufficient.
- Stop once the requested problem is solved and verified.

Response:
- Respond in Traditional Chinese unless another language is requested.
- Keep the final response concise.
- State what changed, how it was verified, and any remaining issue.
- Do not narrate routine tool usage.
- Do not expose hidden reasoning or chain-of-thought.
]]
                end
            end,

            provider = "codex",
            auto_suggestions_provider = "codex",
            providers = {
                ["GLM-5.3-Flash-NVFP4"] = {
                    __inherited_from = "openai",
                    display_name = "GLM-5.3-Flash-NVFP4",
                    endpoint = "https://192.168.61.12/v1",
                    model = "glm-5.3-flash-nvfp4",
                    api_key_name = "LLM_API_KEY",
                    timeout = 1800000,
                    context_window = 262144,
                    allow_insecure = true,
                    use_response_api = false,
                    extra_request_body = {
                        max_tokens = 65536,
                        temperature = 1.0,
                        top_p = 1.0,
                        reasoning_effort = "max",
                    },

                    -- Preserve reasoning_effort after Avante filters the request body.
                    parse_curl_args = function(self, prompt_opts)
                        local request = require("avante.providers.openai").parse_curl_args(self, prompt_opts)
                        if request then
                            request.body.reasoning_effort = "max"
                        end
                        return request
                    end,
                },
                ["Qwen3.8-27B-NVFP4"] = {
                    __inherited_from = "openai",
                    display_name = "Qwen3.8-27B-NVFP4",
                    endpoint = "https://192.168.61.12/v1",
                    model = "qwen3.8-27b-nvfp4",
                    api_key_name = "LLM_API_KEY",
                    timeout = 1800000,
                    context_window = 262144,
                    allow_insecure = true,
                    use_response_api = false,
                    extra_request_body = {
                        max_tokens = 65536,
                        temperature = 1.0,
                        top_p = 0.95,
                        reasoning_effort = "xhigh",
                    },

                    -- Preserve reasoning_effort after Avante filters the request body.
                    parse_curl_args = function(self, prompt_opts)
                        local request = require("avante.providers.openai").parse_curl_args(self, prompt_opts)
                        if request then
                            request.body.reasoning_effort = "xhigh"
                            if request.body.tools and vim.tbl_isempty(request.body.tools) then
                                request.body.tools = nil
                            end
                        end
                        return request
                    end,
                },
            },
            acp_providers = {
                ["github-copilot"] = {
                    command = "npx",

                    args = {
                        "-y",
                        "@github/copilot@1.0.80",
                        "--acp",
                        "--stdio",
                    },

                    env = {
                        HOME = os.getenv("HOME"),
                        PATH = os.getenv("PATH"),
                    },
                },

                codex = {
                    command = "npx",

                    args = {
                        "-y",
                        "@agentclientprotocol/codex-acp@1.1.7",
                    },

                    auth_method = "chat-gpt",

                    env = {
                        NODE_NO_WARNINGS = "1",
                        HOME = os.getenv("HOME"),
                        PATH = os.getenv("PATH"),
                    },
                },
            },

            suggestion = {
                debounce = 1000,
                throttle = 2000,
            },

            behaviour = {
                auto_suggestions = false,
                auto_suggestions_respect_ignore = true,
                auto_set_highlight_group = true,
                auto_set_keymaps = true,
                auto_apply_diff_after_generation = false,
                support_paste_from_clipboard = false,
                minimize_diff = true,
                enable_token_counting = true,
                auto_add_current_file = true,
                auto_approve_tool_permissions = {
                    "bash",
                    "str_replace",
                },
                confirmation_ui_style = "inline_buttons",
                acp_follow_agent_locations = true,
            },

            mappings = {
                suggestion = {
                    accept = "<M-l>",
                    next = "<M-]>",
                    prev = "<M-[>",
                    dismiss = "<C-]>",
                },
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
  install = { colorscheme = { "habamax" } },
  checker = { enabled = true, frequency = 60 * 60 * 24 * 14 },
})
