local M = {}

function M.launch()
  vim.lsp.start {
    name = 'vtsls',
    cmd = { 'vtsls', '--stdio' },
    filetypes = {
      'javascript',
      'javascriptreact',
      'javascript.jsx',
      'typescript',
      'typescriptreact',
      'typescript.tsx',
    },
    root_dir = vim.fs.dirname(vim.fs.find({
      'tsconfig.json',
      'jsconfig.json',
      'package.json',
      '.git',
    }, { upward = true })[1]),
    capabilities = require('user.lsp').make_client_capabilities(),
    settings = {
      typescript = {
        suggest = {
          autoImports = true,
        },
      },
      vtsls = {
        enableMoveToFileCodeAction = true,
      },
    },
  }
end

return M
