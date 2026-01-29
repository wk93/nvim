if vim.g.did_load_treesitter_plugin then
  return
end
vim.g.did_load_treesitter_plugin = true

local config = require('nvim-treesitter.config')
vim.g.skip_ts_context_comment_string_module = true

config.setup {
  auto_install = false,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}

local function should_disable_for_buf(buf)
  local max_filesize = 100 * 1024 -- 100 KiB
  local name = vim.api.nvim_buf_get_name(buf)
  if name == '' then
    return false
  end

  local ok, stats = pcall(vim.loop.fs_stat, name)
  return ok and stats and stats.size > max_filesize
end

vim.api.nvim_create_autocmd('FileType', {
  pattern = {
    'typescript',
    'typescriptreact',
    'javascript',
    'javascriptreact',
    'lua',
    'nix',
    'rust',
    'svelte',
  },
  callback = function(args)
    if vim.bo[args.buf].buftype ~= '' then
      return
    end
    if should_disable_for_buf(args.buf) then
      return
    end

    pcall(vim.treesitter.start, args.buf)
  end,
})
