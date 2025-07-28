if vim.fn.executable('dart') ~= 1 then
  return
end

local root_files = {
  'pubspec.yaml',
  '.git',
}

vim.lsp.start {
  name = 'dartls',
  cmd = { 'dart', 'language-server', '--protocol=lsp' },
  root_dir = vim.fs.dirname(vim.fs.find(root_files, { upward = true })[1]),
  filetypes = { 'dart' },
  capabilities = require('user.lsp').make_client_capabilities(),
}

require('flutter-tools').setup {}
