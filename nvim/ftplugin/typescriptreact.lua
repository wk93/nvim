local vtsls_cmd = 'vtsls'

if vim.fn.executable(vtsls_cmd) ~= 1 then
  return
end

require('user.ts').launch()
