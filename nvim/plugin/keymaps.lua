if vim.g.did_load_keymaps_plugin then
  return
end
vim.g.did_load_keymaps_plugin = true

local map = vim.keymap.set

-- Yank from current position till end of current line
map('n', 'Y', 'y$', { silent = true, desc = '[Y]ank to end of line' })

-- Buffer list navigation
map('n', '[b', vim.cmd.bprevious, { silent = true, desc = 'previous [b]uffer' })
map('n', ']b', vim.cmd.bnext, { silent = true, desc = 'next [b]uffer' })
map('n', '[B', vim.cmd.bfirst, { silent = true, desc = 'first [B]uffer' })
map('n', ']B', vim.cmd.blast, { silent = true, desc = 'last [B]uffer' })

-- -- Window navigation with Ctrl + h/j/k/l
map('n', '<C-h>', '<C-w>h', { silent = true, desc = 'move to the left split' })
map('n', '<C-j>', '<C-w>j', { silent = true, desc = 'move to the below split' })
map('n', '<C-k>', '<C-w>k', { silent = true, desc = 'move to the above split' })
map('n', '<C-l>', '<C-w>l', { silent = true, desc = 'move to the right split' })

-- Window resizing with Alt + h/j/k/l
map('n', '<A-h>', '<C-w><', { silent = true, desc = 'decrease window width' })
map('n', '<A-l>', '<C-w>>', { silent = true, desc = 'increase window width' })
map('n', '<A-k>', '<C-w>+', { silent = true, desc = 'increase window height' })
map('n', '<A-j>', '<C-w>-', { silent = true, desc = 'decrease window height' })

-- Equalize all window sizes
map('n', '<A-0>', '<C-w>=', { silent = true, desc = '' })
