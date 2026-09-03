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

local glm_provider_name = "GLM-5.3-Flash-NVFP4"
local qwen_provider_name = "Qwen3.8-27B-NVFP4"
local llm_endpoint = "https://192.168.61.12/v1"
local llm_api_key_name = "LLM_API_KEY"
local glm_system_prompt = [[
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
local qwen_system_prompt = [[
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

    -- GitHub Copilot
    --
    -- Authenticate with:
    --   :Copilot auth
    --
    -- Then sign in with the GitHub account that owns the Copilot license:
    --   getac.copilot4@gmail.com
    {
      "zbirenbaum/copilot.lua",
      cmd = "Copilot",
      event = { "InsertEnter", "BufReadPost" },

      -- Avante's Copilot provider expects copilot.lua to be initialized.
      -- Keep setup explicit rather than relying on Lazy.nvim's inferred main module.
      config = function(_, opts)
        require("copilot").setup(opts)
      end,

      opts = {
        -- Recommended by Avante for the standard GitHub Copilot endpoint.
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
          { "zbirenbaum/copilot.lua" }, -- use the same Copilot backend as Avante
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
        branch = "main",

        build = "make",
        event = "VeryLazy",
        version = false,

        ---@module 'avante'
        ---@type avante.Config
        opts = {
            instructions_file = "avante.md",

            mode = "agentic",

            -- Apply the requested GLM rules without changing Codex or Copilot.
            system_prompt = function()
                if require("avante.config").provider == glm_provider_name then
                    return glm_system_prompt
                end
                if require("avante.config").provider == qwen_provider_name then
                    return qwen_system_prompt
                end
            end,

            -- GLM handles chat/agent work; Qwen handles typing suggestions.
            provider = glm_provider_name,
            auto_suggestions_provider = qwen_provider_name,
            providers = {
                [glm_provider_name] = {
                    __inherited_from = "openai",
                    display_name = glm_provider_name,
                    endpoint = llm_endpoint,
                    model = "glm-5.3-flash-nvfp4",
                    api_key_name = llm_api_key_name,
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

                    -- Avante removes reasoning_effort for model names it does
                    -- not recognize as reasoning models. LiteLLM expects it for
                    -- this GLM deployment, so restore it after body generation.
                    parse_curl_args = function(self, prompt_opts)
                        local request = require("avante.providers.openai").parse_curl_args(self, prompt_opts)
                        if request then
                            request.body.reasoning_effort = "max"
                        end
                        return request
                    end,
                },
                [qwen_provider_name] = {
                    __inherited_from = "openai",
                    display_name = qwen_provider_name,
                    endpoint = llm_endpoint,
                    model = "qwen3.8-27b-nvfp4",
                    api_key_name = llm_api_key_name,
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

                    -- Preserve the gateway-specific reasoning parameter for
                    -- this custom model name after Avante filters the body.
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
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates every 14 days
  checker = { enabled = true, frequency = 60 * 60 * 24 * 14 },
})
