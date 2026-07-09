local filetypes = {"c", "cpp", "haskell", "json", "html", "cmake", "rust"}
local pairgroup = vim.api.nvim_create_augroup("PairGroup", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = pairgroup,
  pattern = filetypes,
  command = "source $HOME/.config/nvim/lua/plugins/pairs.lua",
})

vim.api.nvim_create_autocmd("FileType", {
  group = pairgroup,
  pattern = filetypes,
  command = "source $HOME/.config/nvim/lua/plugins/coc.lua",
})

vim.api.nvim_create_user_command("BearMake", function()
  local project_root = vim.fn.getcwd()

  local log_buf = nil
  local log_win = nil

  local function open_log_window()
    if log_buf and vim.api.nvim_buf_is_valid(log_buf) then
      if log_win and vim.api.nvim_win_is_valid(log_win) then
        return
      end
    else
      log_buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_name(log_buf, "BearMake Output")
      vim.bo[log_buf].buftype = "nofile"
      vim.bo[log_buf].bufhidden = "wipe"
      vim.bo[log_buf].swapfile = false
      vim.bo[log_buf].filetype = "make"
    end

    vim.cmd("botright 15split")
    log_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(log_win, log_buf)
    vim.wo[log_win].wrap = false
    vim.wo[log_win].number = false
    vim.wo[log_win].relativenumber = false
  end

  local function append_log(lines)
    if not lines or #lines == 0 then
      return
    end

    vim.schedule(function()
      open_log_window()

      local cleaned = {}
      for _, line in ipairs(lines) do
        if line ~= nil and line ~= "" then
          table.insert(cleaned, line)
        end
      end

      if #cleaned == 0 then
        return
      end

      vim.api.nvim_buf_set_lines(log_buf, -1, -1, false, cleaned)

      if log_win and vim.api.nvim_win_is_valid(log_win) then
        vim.api.nvim_win_set_cursor(log_win, { vim.api.nvim_buf_line_count(log_buf), 0 })
      end
    end)
  end

  local function append_text(text)
    append_log(vim.split(text, "\n", { plain = true }))
  end

  local function run_bear_make()
    append_text("")
    append_text("========== bear -- make all ==========")

    vim.fn.jobstart({ "bear", "--", "make", "all" }, {
      cwd = project_root,
      stdout_buffered = false,
      stderr_buffered = false,

      on_stdout = function(_, data)
        append_log(data)
      end,

      on_stderr = function(_, data)
        append_log(data)
      end,

      on_exit = function(_, code)
        vim.schedule(function()
          if code == 0 then
            append_text("")
            append_text("compile_commands.json generated")
            vim.notify("compile_commands.json generated")

            vim.cmd("CocRestart")
          else
            append_text("")
            append_text("bear -- make all failed: exit code " .. code)
            vim.notify("bear -- make all failed: exit code " .. code, vim.log.levels.ERROR)
          end
        end)
      end,
    })
  end

  open_log_window()

  vim.api.nvim_buf_set_lines(log_buf, 0, -1, false, {
    "========== make clean ==========",
  })

  vim.fn.jobstart({ "make", "clean" }, {
    cwd = project_root,
    stdout_buffered = false,
    stderr_buffered = false,

    on_stdout = function(_, data)
      append_log(data)
    end,

    on_stderr = function(_, data)
      append_log(data)
    end,

    on_exit = function(_, code)
      if code == 0 then
        vim.schedule(run_bear_make)
      else
        vim.schedule(function()
          append_text("")
          append_text("make clean failed: exit code " .. code)
          vim.notify("make clean failed: exit code " .. code, vim.log.levels.ERROR)
        end)
      end
    end,
  })
end, {})
