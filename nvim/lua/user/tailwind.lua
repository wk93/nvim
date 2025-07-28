local M = { launch = function() end }

local tailwind_cmd = 'tailwindcss-language-server'

if vim.fn.executable(tailwind_cmd) ~= 1 then
  return M
end

local function find_root()
  local root = vim.fs.find({
    'tailwind.config.js',
    'tailwind.config.cjs',
    'tailwind.config.mjs',
    'postcss.config.js',
    'postcss.config.cjs',
    'postcss.config.mjs',
    'package.json',
  }, { upward = true })[1]
  return root and vim.fs.dirname(root) or vim.loop.cwd()
end

function M.launch()
  vim.lsp.start {
    name = 'tailwindcss_ls',
    cmd = { tailwind_cmd, '--stdio' },
    filetypes = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact', 'vue', 'astro', 'svelte' },
    root_dir = find_root(),
    capabilities = require('user.lsp').make_client_capabilities(),
  }
end

return M
