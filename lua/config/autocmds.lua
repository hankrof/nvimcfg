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

vim.opt.autoread = true
vim.api.nvim_create_autocmd({
  "FocusGained",
  "BufEnter",
  "CursorHold",
  "CursorHoldI",
  "TermLeave",
}, {
  callback = function()
    if vim.fn.getcmdwintype() == "" then
      vim.cmd("checktime")
    end
  end,
})

vim.api.nvim_create_user_command("BearMake", function(opts)
  local uv = vim.uv or vim.loop

  local function join_path(parent, child)
    return parent:gsub("/+$", "") .. "/" .. child
  end

  local function is_file(path)
    local stat = uv.fs_stat(path)
    return stat ~= nil and stat.type == "file"
  end

  local function is_directory(path)
    local stat = uv.fs_stat(path)
    return stat ~= nil and stat.type == "directory"
  end

  local function cmake_source_root_from_cache(cache_path)
    local cache = io.open(cache_path, "r")
    if cache == nil then
      return nil
    end

    for line in cache:lines() do
      local source_root = line:match("^CMAKE_HOME_DIRECTORY:INTERNAL=(.+)$")
      if source_root ~= nil then
        cache:close()
        return source_root
      end
    end

    cache:close()
    return nil
  end

  local function detect_project(start_path)
    local path = vim.fn.fnamemodify(start_path, ":p"):gsub("/+$", "")

    while path ~= "" do
      -- Prefer CMake when both CMakeLists.txt and a Makefile exist in the same
      -- directory. The Makefile may only be a convenience wrapper.
      if is_file(join_path(path, "CMakeLists.txt")) then
        return {
          kind = "cmake",
          root = path,
        }
      end

      -- A configured CMake build directory normally contains both a generated
      -- Makefile/build.ninja and CMakeCache.txt. Detect the cache first so the
      -- generated backend is not mistaken for a standalone Makefile project.
      local cache_path = join_path(path, "CMakeCache.txt")
      if is_file(cache_path) then
        local source_root = cmake_source_root_from_cache(cache_path)
        if source_root ~= nil and is_file(join_path(source_root, "CMakeLists.txt")) then
          return {
            kind = "cmake",
            root = source_root,
            build_dir = path,
          }
        end
      end

      for _, makefile in ipairs({ "GNUmakefile", "Makefile", "makefile" }) do
        if is_file(join_path(path, makefile)) then
          return {
            kind = "make",
            root = path,
            makefile = makefile,
          }
        end
      end

      local parent = vim.fn.fnamemodify(path, ":h")
      if parent == path then
        break
      end

      path = parent
    end

    return nil
  end

  local project = detect_project(vim.fn.getcwd())
  if project == nil then
    vim.notify(
      "BearMake: no CMakeLists.txt or Makefile was found in the current directory or its parents",
      vim.log.levels.ERROR
    )
    return
  end

  if vim.fn.executable("bear") ~= 1 then
    vim.notify("BearMake: 'bear' was not found in PATH", vim.log.levels.ERROR)
    return
  end

  local required_builder = project.kind == "cmake" and "cmake" or "make"
  if vim.fn.executable(required_builder) ~= 1 then
    vim.notify("BearMake: '" .. required_builder .. "' was not found in PATH", vim.log.levels.ERROR)
    return
  end

  local project_root = project.root
  local compile_commands = join_path(project_root, "compile_commands.json")
  local argument = opts.args ~= "" and opts.args or nil

  local log_buf = nil
  local log_win = nil

  local function open_log_window()
    if log_buf and vim.api.nvim_buf_is_valid(log_buf) then
      if log_win and vim.api.nvim_win_is_valid(log_win) then
        return
      end
    else
      log_buf = vim.api.nvim_create_buf(false, true)

      local project_name = vim.fn.fnamemodify(project_root, ":t")
      local log_name = "BearMake Output [" .. project_name .. "]"
      if vim.fn.bufnr(log_name) ~= -1 then
        log_name = log_name .. " " .. tostring(uv.hrtime())
      end

      vim.api.nvim_buf_set_name(log_buf, log_name)
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
        vim.api.nvim_win_set_cursor(log_win, {
          vim.api.nvim_buf_line_count(log_buf),
          0,
        })
      end
    end)
  end

  local function append_text(text)
    append_log(vim.split(text, "\n", { plain = true }))
  end

  local function command_to_string(command)
    local escaped = {}
    for _, item in ipairs(command) do
      table.insert(escaped, vim.fn.shellescape(item))
    end
    return table.concat(escaped, " ")
  end

  local function run_job(command, on_success)
    append_text("")
    append_text("========== " .. command_to_string(command) .. " ==========")

    local job_id = vim.fn.jobstart(command, {
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
            on_success()
            return
          end

          local message = command_to_string(command) .. " failed: exit code " .. code
          append_text("")
          append_text(message)
          vim.notify("BearMake: " .. message, vim.log.levels.ERROR)
        end)
      end,
    })

    if job_id <= 0 then
      local message = "failed to start: " .. command_to_string(command)
      append_text(message)
      vim.notify("BearMake: " .. message, vim.log.levels.ERROR)
    end
  end

  local function remove_old_compile_commands()
    if is_file(compile_commands) then
      local ok, error_message = uv.fs_unlink(compile_commands)
      if not ok then
        append_text("Unable to remove old compile_commands.json: " .. tostring(error_message))
      end
    end
  end

  local function finish()
    if not is_file(compile_commands) then
      local message = "build succeeded, but " .. compile_commands .. " was not generated"
      append_text("")
      append_text(message)
      vim.notify("BearMake: " .. message, vim.log.levels.WARN)
      return
    end

    append_text("")
    append_text("compile_commands.json generated: " .. compile_commands)
    vim.notify("compile_commands.json generated")
    vim.cmd("CocRestart")
  end

  local function run_make_project()
    local target = argument or "all"

    run_job({ "make", "clean" }, function()
      remove_old_compile_commands()
      run_job({ "bear", "--", "make", "-j", target }, finish)
    end)
  end

  local function run_cmake_project()
    local build_dir = argument or project.build_dir or "build"
    if not build_dir:match("^/") then
      build_dir = join_path(project_root, build_dir)
    end

    local configure_command = {
      "cmake",
      "-S",
      project_root,
      "-B",
      build_dir,
    }

    local function run_bear_build()
      remove_old_compile_commands()
      run_job({ "bear", "--", "cmake", "--build", build_dir, "--parallel" }, finish)
    end

    local function clean_then_build()
      if not is_directory(build_dir) then
        run_bear_build()
        return
      end

      run_job({ "cmake", "--build", build_dir, "--target", "clean" }, run_bear_build)
    end

    -- Reconfigure on every invocation so changes to CMakeLists.txt are applied.
    -- CMake reuses the existing cache, generator, and cross-toolchain settings.
    run_job(configure_command, clean_then_build)
  end

  open_log_window()
  vim.api.nvim_buf_set_lines(log_buf, 0, -1, false, {
    "BearMake project root: " .. project_root,
    "Detected project type: " .. project.kind,
  })

  if project.kind == "cmake" then
    run_cmake_project()
  else
    run_make_project()
  end
end, {
  nargs = "?",
  desc = "Generate compile_commands.json with Bear for Makefile or CMake projects",
})
