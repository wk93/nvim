if vim.g.did_load_completion_plugin then
  return
end
vim.g.did_load_completion_plugin = true

local blink = require('blink.cmp')

blink.setup {
  cmdline = { enabled = true },
  completion = {
    documentation = { auto_show = true },
    ghost_text = {
      enabled = true,
    },
    menu = {
      auto_show = true,
    },
  },
  keymap = {
    ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
    ['<C-e>'] = { 'hide', 'fallback' },
    ['<CR>'] = { 'accept', 'fallback' },

    ['<C-n>'] = { 'snippet_forward', 'fallback' },
    ['<C-p>'] = { 'snippet_backward', 'fallback' },

    ['<Up>'] = { 'select_prev', 'fallback' },
    ['<Down>'] = { 'select_next', 'fallback' },
    ['<S-Tab>'] = { 'select_prev', 'fallback_to_mappings' },
    ['<Tab>'] = { 'select_next', 'fallback_to_mappings' },

    ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
    ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },

    ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
  },
}
