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
      draw = {
        components = {
          -- customize the drawing of kind icons
          kind_icon = {
            text = function(ctx)
              -- default kind icon
              local icon = ctx.kind_icon
              -- if LSP source, check for color derived from documentation
              if ctx.item.source_name == 'LSP' then
                local color_item = require('nvim-highlight-colors').format(ctx.item.documentation, { kind = ctx.kind })
                if color_item and color_item.abbr ~= '' then
                  icon = color_item.abbr
                end
              end
              return icon .. ctx.icon_gap
            end,
            highlight = function(ctx)
              -- default highlight group
              local highlight = 'BlinkCmpKind' .. ctx.kind
              -- if LSP source, check for color derived from documentation
              if ctx.item.source_name == 'LSP' then
                local color_item = require('nvim-highlight-colors').format(ctx.item.documentation, { kind = ctx.kind })
                if color_item and color_item.abbr_hl_group then
                  highlight = color_item.abbr_hl_group
                end
              end
              return highlight
            end,
          },
        },
      },
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
