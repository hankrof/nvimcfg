local M = {}

function M.setup()
    if vim.env.NVIM_CLANG_REFLECTION == "0" then
        return false
    end

    local source = debug.getinfo(1, "S").source:sub(2)
    local root = vim.fn.resolve(vim.fn.fnamemodify(source, ":h:h:h"))
    local prefix = vim.env.NVIM_CLANG_REFLECTION_PREFIX or (root .. "/.reflection/install")
    prefix = vim.fn.resolve(vim.fn.fnamemodify(prefix, ":p")):gsub("/+$", "")
    if vim.fn.executable(prefix .. "/bin/clangd") ~= 1
        or vim.fn.filereadable(prefix .. "/include/c++/v1/meta") ~= 1 then
        return false
    end

    local config = vim.g.coc_user_config or {}
    config["clangd.path"] = root .. "/scripts/clangd-reflection.sh"
    config["clangd.checkUpdates"] = false
    local args = vim.deepcopy(config["clangd.arguments"] or {})
    local prefix_arg = "--reflection-prefix=" .. prefix
    if not vim.tbl_contains(args, prefix_arg) then
        table.insert(args, 1, prefix_arg)
    end
    local query_driver = "--query-driver=" .. prefix .. "/bin/clang++"
    if not vim.tbl_contains(args, query_driver) then
        table.insert(args, query_driver)
    end
    if not vim.tbl_contains(args, "--enable-config") then
        table.insert(args, "--enable-config")
    end
    config["clangd.arguments"] = args
    vim.g.coc_user_config = config
    return true
end

return M
