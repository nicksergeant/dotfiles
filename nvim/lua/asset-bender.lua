local Job = require'plenary.job'
local log = require('plenary.log').new({
  plugin = 'asset-bender',
  use_console = false,
})

local path_join = require('tools').path_join;
local buffer_find_root_dir = require('tools').buffer_find_root_dir;
local filetypes = require('filetypes').defaultConfig;

local function is_dir(filename)
  local stat = vim.loop.fs_stat(filename)
  return stat and stat.type == 'directory' or false
end

local path_sep = vim.loop.os_uname().sysname == "Windows" and "\\" or "/"
local function dirname(filepath)
  local is_changed = false
  local result = filepath:gsub(path_sep.."([^"..path_sep.."]+)$", function()
    is_changed = true
    return ""
  end)
  return result, is_changed
end

local javascript_lsps = {}

local function getLogPath()
  return vim.lsp.get_log_path()
end

local function startAssetBenderProcess(workspaces)
  log.info('Asset Bender starting new client')
  log.info('starting NEW asset-bender with workspaces of "' .. vim.inspect(workspaces))

  local newJob = Job:new({
    command = 'bpx',
    args = {'asset-bender', 'reactor', 'host', '--host-most-recent', 100, workspaces},
    on_exit = function(j, return_val)
      log.info(return_val)
      log.info(j:result())
    end,
    on_stdout = function(error, data)
      log.info(error)
      log.info(data) 
    end,
    on_stderr = function(error, data)
      log.info(error)
      log.info(data) 
    end,
  }):start()

  return newJob
end

function check_start_javascript_lsp()
  local bufnr = vim.api.nvim_get_current_buf()
  if not filetypes[vim.api.nvim_buf_get_option(bufnr, 'filetype')] then
    return
  end
  local root_dir = buffer_find_root_dir(bufnr, function(dir)
    return is_dir(path_join(dir, '.git'))
  end)
  if not root_dir then 
    log.info('we couldnt find a root directory, ending')
    return 
  end
  local client_id = javascript_lsps[root_dir]
  if client_id then
    log.info('already found a client_id, skipping')
  end
  if not client_id then
    client_id = startAssetBenderProcess(root_dir)
    javascript_lsps[root_dir] = client_id
  end
end

vim.api.nvim_command [[autocmd BufReadPost * lua check_start_javascript_lsp()]]

log.info('Asset bender plugin intialized')
