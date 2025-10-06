if vim.fn.executable('svelte-language-server') ~= 1 and vim.fn.executable('svelteserver') ~= 1 then
  return
end

local svelte_cmd = vim.fn.executable('svelteserver') == 1 and { 'svelteserver', '--stdio' }
  or { 'svelte-language-server', '--stdio' }

local svelte_root = {
  'svelte.config.ts',
  'svelte.config.js',
  'svelte.config.cjs',
  'svelte.config.mjs',
  'package.json',
  'tsconfig.json',
  'tsconfig.svelte.json',
  '.git',
}

vim.lsp.start {
  name = 'svelte',
  cmd = svelte_cmd,
  root_dir = vim.fs.dirname(vim.fs.find(svelte_root, { upward = true })[1]),
  filetypes = { 'svelte' },
  single_file_support = true,
  capabilities = require('user.lsp').make_client_capabilities(),
  settings = {
    svelte = {
      plugin = {
        typescript = {
          enable = true, -- TS w <script lang="ts">
          diagnostics = { enable = true },
        },
        svelte = {
          compilerWarnings = { ['a11y-no-onchange'] = 'ignore' },
        },
        css = { diagnostics = { enable = true } },
      },
    },
  },
}
