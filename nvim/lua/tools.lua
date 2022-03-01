local api = vim.api

local Job = require("plenary.job")
local log = require("plenary.log").new({
    plugin = "asset-bender",
    use_console = false
})

local M = {}

M.path_sep = vim.loop.os_uname().sysname == "Windows" and "\\" or "/"

function M.LSPLogs()
    local logFile = vim.lsp.get_log_path()
    api.nvim_command("split|term tail -f " .. logFile)
end

function M.GitRoot()
    local git_root = vim.fn.systemlist("git -C " .. vim.loop.cwd() ..
                                           " rev-parse --show-toplevel")[1]
    local project_directory = git_root
    if not git_root then project_directory = vim.loop.cwd() end
    return project_directory
end

function M.telescope_files()
    local root = M.GitRoot()
    require("telescope.builtin").find_files({cwd = root})
end

function M.telescope_grep()
    local root = M.GitRoot()
    require("telescope.builtin").live_grep({cwd = root})
end

function M.telescope_buffers()
    local root = M.GitRoot()
    require('telescope.builtin').buffers({initial_mode = "normal"})
end

function M.telescope_diagnostics(opts)
    opts = {}
    local utils = require "telescope.utils"
    local pickers = require "telescope.pickers"
    local locations = utils.diagnostics_to_tbl(opts)

    if vim.tbl_isempty(locations) then
        print "No diagnostics found"
        return
    end

    opts.path_display = utils.get_default(opts.path_display, "hidden")
    pickers.new(opts, {
        prompt_title = "LSP Document Diagnostics",
        finder = require('telescope.finders').new_table {
            results = locations,
            entry_maker = opts.entry_maker or
                require("telescope.make_entry").gen_from_lsp_diagnostics(opts)
        },
        previewer = require('telescope.previewers').new_termopen_previewer({
            get_command = function(entry, status)
                return {'echo', entry.text}
            end
        })
    }):find()

end

-- Asumes filepath is a file.
local function dirname(filepath)
    local is_changed = false
    local result = filepath:gsub(M.path_sep .. "([^" .. M.path_sep .. "]+)$",
                                 function()
        is_changed = true
        return ""
    end)
    return result, is_changed
end

-- Ascend the buffer's path until we find the rootdir.
-- is_root_path is a function which returns bool
function M.buffer_find_root_dir(bufnr, is_root_path)
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    if vim.fn.filereadable(bufname) == 0 then return nil end
    local dir = bufname
    -- Just in case our algo is buggy, don't infinite loop.
    for _ = 1, 100 do
        local did_change
        dir, did_change = dirname(dir)
        if is_root_path(dir, bufname) then return dir, bufname end
        -- If we can't ascend further, then stop looking.
        if not did_change then return nil end
    end
end

function M.path_join(...) return
    table.concat(vim.tbl_flatten({...}), M.path_sep) end

function M.file_exists(fname)
    local stat = vim.loop.fs_stat(fname)
    return (stat and stat.type) or false
end

function M.is_dir(filename)
    local stat = vim.loop.fs_stat(filename)
    return stat and stat.type == "directory" or false
end

function M.open_file(file) vim.cmd("e " .. file) end

function M.FileExplorer()
    if M.FileExplorerHasAlreadyBeenOpened == true then
        vim.cmd("Rex")
    else
        vim.cmd("Ex")
        M.FileExplorerHasAlreadyBeenOpened = true;
    end
end

return M
