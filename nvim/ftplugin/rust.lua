if vim.fn.executable('rust-analyzer') ~= 1 then
  return
end

vim.lsp.start {
  name = 'rust-analyzer',
  cmd = { 'rust-analyzer' },
  settings = {
    ['rust-analyzer'] = {
      cargo = {
        features = 'all',
      },
      check = {
        command = 'clippy',
      },
      files = {
        excludeDirs = {
          '.direnv',
        },
      },
    },
  },
  capabilities = require('user.lsp').make_client_capabilities(),
}
