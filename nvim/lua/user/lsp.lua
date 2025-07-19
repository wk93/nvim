---@mod user.lsp
---
---@brief [[
---LSP related functions
---@brief ]]

local M = {}

---Gets a 'ClientCapabilities' object, describing the LSP client capabilities
---Extends the object with capabilities provided by plugins.
---@return lsp.ClientCapabilities
function M.make_client_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()

  -- Add blink.cmp capabilities
  local blink = require('blink.cmp')
  local blink_capabilities = blink.get_lsp_capabilities({}, false)

  capabilities = vim.tbl_deep_extend('force', capabilities, blink_capabilities)

  -- Add any additional plugin capabilities here.
  -- Make sure to follow the instructions provided in the plugin's docs.
  return capabilities
end

return M
