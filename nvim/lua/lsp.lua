local util = require("lspconfig/util")
local Job = require("plenary.job")

function getIsHubspotMachine()
  local result = ""
  local testing = {}
  Job:new({
    command = "ls",
    args = {vim.env.HOME .. '/.isHubspotMachine'},
    on_exit = function(j, return_val)
      result = return_val
      testing = j
    end
  }):sync()

  return result == 0
end

function getLogPath() return vim.lsp.get_log_path() end

function getTsserverPath()
  local result = "/lib/tsserver.js"
  Job:new({
    command = "bpx",
    args = {"--path", "hs-typescript"},
    on_exit = function(j, return_val)
      local path = j:result()[1]
      result = path .. result
    end
  }):sync()

  return result
end

local capabilities = vim.lsp.protocol.make_client_capabilities()

capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

local customPublishDiagnosticFunction = function(_, result, ctx, config)
  local filter = function(fun, t)
    local res = {}
    for _, item in ipairs(t) do
      if fun(item) then res[#res + 1] = item end
    end

    return res
  end
  local raw_diagnostics = result.diagnostics

  local filtered_diagnostics = filter(function(diagnostic)
    local diagnostic_code = diagnostic.code
    local diagnostic_source = diagnostic.source
    return not (diagnostic_code == 7016 and diagnostic_source ==
    "typescript")
  end, raw_diagnostics)

  result.diagnostics = filtered_diagnostics

  return vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx, config)
end

local isHubspotMachine = getIsHubspotMachine()

if isHubspotMachine then
  local bend = require("bend")
  bend.setup()

  vim.lsp.config('ts_ls', {
    cmd = {
      "typescript-language-server", "--log-level",
      "2", "--tsserver-log-verbosity", "terse",
      "--tsserver-log-file", getLogPath(), "--tsserver-path",
      bend.getTsServerPathForCurrentFile(), "--stdio"
    },
    root_dir = util.root_pattern("package.json"),
    filetypes = {
      "javascript", "javascriptreact", "javascript.jsx", "typescript",
      "typescriptreact", "typescript.tsx"
    },
    handlers = {
      ["textDocument/publishDiagnostics"] = vim.lsp.with(
      customPublishDiagnosticFunction, {})
    },
    capabilities = capabilities
  })
  vim.lsp.enable('ts_ls')
else
  vim.lsp.config('ts_ls', {
    root_dir = util.root_pattern("package.json"),
    workspace_required = true,
    capabilities = capabilities
  })
  vim.lsp.enable('ts_ls')
end

vim.lsp.enable('graphql')
vim.lsp.enable('tailwindcss')
vim.lsp.enable('yamlls')
vim.lsp.config('denols', {
  root_dir = util.root_pattern("deno.json", "deno.jsonc")
})
vim.lsp.enable('denols')

require("lspkind").init({})

vim.api.nvim_set_keymap("n", "ga", "<cmd>lua vim.lsp.buf.code_action()<CR>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "gi", "<cmd>lua vim.lsp.buf.hover()<CR>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "go", "<cmd>lua vim.lsp.buf.definition()<CR>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "mv", "<cmd>lua vim.lsp.buf.rename()<CR>", {noremap = true, silent = true})
vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {border = 'single'})
vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, {border = 'single'})
