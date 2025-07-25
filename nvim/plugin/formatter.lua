if vim.g.did_load_formatter_plugin then
  return
end
vim.g.did_load_formatter_plugin = true
local conform = require('conform')

conform.setup {
  formatters_by_ft = {
    lua = { 'stylua' },
    nix = { 'alejandra' },

    javascript = { 'prettierd' },
    javascriptreact = { 'prettierd' },
    typescript = { 'prettierd' },
    typescriptreact = { 'prettierd' },
    json = { 'prettierd' },
    yaml = { 'prettierd' },
    html = { 'prettierd' },
    css = { 'prettierd' },
    markdown = { 'prettierd' },
  },
  default_format_opts = {
    lsp_format = 'fallback',
  },
  format_on_save = {
    lsp_format = 'fallback',
    timeout_ms = 500,
  },
  notify_on_error = true,
}
