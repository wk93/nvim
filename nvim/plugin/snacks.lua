if vim.g.did_load_snacks_plugin then
  return
end

vim.g.did_load_snacks_plugin = true

require('snacks').setup {
  bigfile = { enable = true, size = 2 * 1024 * 1024 },
  indent = { enable = true },
  input = { enable = true },
  picker = {
    enable = true,
    db = { sqlite3_path = vim.fn.getenv('LIBSQLITE_CLIB_PATH') },
  },
}

vim.keymap.set('n', '<leader>/', function()
  Snacks.picker.grep()
end, { desc = 'grep' })
vim.keymap.set('n', '<leader>fb', function()
  Snacks.picker.buffers()
end, { desc = 'get buffers' })
vim.keymap.set('n', '<leader>ff', function()
  Snacks.picker.files()
end, { desc = 'find files' })
vim.keymap.set('n', '<leader>fg', function()
  Snacks.picker.files()
end, { desc = 'find git files' })
vim.keymap.set('n', '<leader>fr', function()
  Snacks.picker.recent()
end, { desc = 'find recent files' })
