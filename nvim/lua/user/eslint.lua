local M = { launch = function() end }

local eslint_cmd = 'vscode-eslint-language-server'
if vim.fn.executable(eslint_cmd) ~= 1 then
  return M
end

local lsp = vim.lsp

local eslint_config_files = {
  '.eslintrc',
  '.eslintrc.js',
  '.eslintrc.cjs',
  '.eslintrc.yaml',
  '.eslintrc.yml',
  '.eslintrc.json',
  'eslint.config.js',
  'eslint.config.mjs',
  'eslint.config.cjs',
  'eslint.config.ts',
  'eslint.config.mts',
  'eslint.config.cts',
}

-- Minimalny zamiennik lspconfig.util.insert_package_json(...)
-- Jeśli w package.json istnieje klucz "eslintConfig", traktujemy package.json jak "config marker"
local function insert_package_json(config_files, key, filename)
  local out = {}
  for _, f in ipairs(config_files) do
    out[#out + 1] = f
  end

  -- tylko jeśli w drzewie jest package.json, który zawiera "eslintConfig"
  local pkg = vim.fs.find('package.json', { path = filename, upward = true, type = 'file', limit = 1 })[1]
  if not pkg then
    return out
  end

  local ok, lines = pcall(vim.fn.readfile, pkg)
  if not ok or not lines then
    return out
  end

  local content = table.concat(lines, '\n')
  -- proste (ale skuteczne) sprawdzenie obecności klucza
  if content:match('"' .. key .. '"%s*:') then
    out[#out + 1] = 'package.json'
  end

  return out
end

local function find_root(bufnr)
  -- exclude deno
  if vim.fs.root(bufnr, { 'deno.json', 'deno.jsonc', 'deno.lock' }) then
    return nil
  end

  -- monorepo root markers
  local root_markers = { 'package-lock.json', 'yarn.lock', 'pnpm-lock.yaml', 'bun.lockb', 'bun.lock' }
  root_markers = vim.fn.has('nvim-0.11.3') == 1 and { root_markers, { '.git' } }
    or vim.list_extend(root_markers, { '.git' })

  local project_root = vim.fs.root(bufnr, root_markers) or vim.fn.getcwd()

  local filename = vim.api.nvim_buf_get_name(bufnr)
  if filename == '' then
    return nil
  end

  -- czy bufor jest w projekcie z ESLint configiem?
  local files = insert_package_json(eslint_config_files, 'eslintConfig', filename)
  local found = vim.fs.find(files, {
    path = filename,
    type = 'file',
    limit = 1,
    upward = true,
    stop = vim.fs.dirname(project_root),
  })[1]

  if not found then
    return nil
  end

  return project_root
end

-- sync (manual), może blokować UI
local function eslint_fix_all_sync(client, bufnr, timeout_ms)
  if not client or client.is_stopped() then
    return
  end

  client:request_sync('workspace/executeCommand', {
    command = 'eslint.applyAllFixes',
    arguments = {
      {
        uri = vim.uri_from_bufnr(bufnr),
        version = lsp.util.buf_versions[bufnr],
      },
    },
  }, timeout_ms or 1000, bufnr)
end

-- async, nie blokuje zapisu (fix po zapisie + auto-write jeśli są zmiany)
local function eslint_fix_all_async(client, bufnr)
  if not client or client.is_stopped() then
    return
  end

  if vim.b[bufnr].eslint_fix_inflight then
    return
  end
  vim.b[bufnr].eslint_fix_inflight = true

  client:request('workspace/executeCommand', {
    command = 'eslint.applyAllFixes',
    arguments = {
      {
        uri = vim.uri_from_bufnr(bufnr),
        version = lsp.util.buf_versions[bufnr],
      },
    },
  }, function()
    -- applyEdit może przyjść chwilę później
    vim.defer_fn(function()
      vim.b[bufnr].eslint_fix_inflight = false

      if not vim.api.nvim_buf_is_valid(bufnr) then
        return
      end

      -- jeśli eslint coś poprawił, zapisujemy ponownie (bez pętli autocmd)
      if vim.bo[bufnr].modified and not vim.b[bufnr].eslint_fix_suppress_write then
        vim.b[bufnr].eslint_fix_suppress_write = true
        vim.api.nvim_buf_call(bufnr, function()
          vim.cmd('silent noautocmd write')
        end)
        vim.b[bufnr].eslint_fix_suppress_write = false
      end
    end, 50)
  end, bufnr)
end

function M.launch()
  local bufnr = vim.api.nvim_get_current_buf()
  local root_dir = find_root(bufnr)
  if not root_dir then
    return
  end

  vim.lsp.start {
    name = 'eslint',
    cmd = { eslint_cmd, '--stdio' },
    filetypes = {
      'javascript',
      'javascriptreact',
      'javascript.jsx',
      'typescript',
      'typescriptreact',
      'typescript.tsx',
      'vue',
      'svelte',
      'astro',
      'htmlangular',
    },
    root_dir = root_dir,
    reuse_client = function(client, config)
      return client.name == config.name and client.config.root_dir == config.root_dir
    end,
    capabilities = require('user.lsp').make_client_capabilities(),

    on_attach = function(client, attached_bufnr)
      -- ręczne wywołanie (sync)
      vim.api.nvim_buf_create_user_command(attached_bufnr, 'LspEslintFixAll', function()
        eslint_fix_all_sync(client, attached_bufnr, 2000)
      end, {})

      -- FIX ON SAVE (BufWritePost) => bez freeza UI
      local group = vim.api.nvim_create_augroup('EslintFixOnSave', { clear = false })
      vim.api.nvim_clear_autocmds { group = group, buffer = attached_bufnr }

      vim.api.nvim_create_autocmd('BufWritePost', {
        group = group,
        buffer = attached_bufnr,
        desc = 'ESLint: apply all fixes after save (async)',
        callback = function()
          if vim.b[attached_bufnr].eslint_fix_suppress_write then
            return
          end
          eslint_fix_all_async(client, attached_bufnr)
        end,
      })
    end,

    settings = {
      validate = 'on',
      ---@diagnostic disable-next-line: assign-type-mismatch
      packageManager = nil,
      useESLintClass = false,
      experimental = { useFlatConfig = false },

      run = 'onSave',

      codeActionOnSave = { enable = false, mode = 'all' },

      format = false,

      quiet = false,
      onIgnoredFiles = 'off',
      rulesCustomizations = {},
      problems = { shortenToSingleLine = false },
      nodePath = '',
      workingDirectory = { mode = 'location' },
      codeAction = {
        disableRuleComment = { enable = true, location = 'separateLine' },
        showDocumentation = { enable = true },
      },
    },

    before_init = function(_, config)
      local rd = config.root_dir
      if not rd then
        return
      end

      config.settings = config.settings or {}
      config.settings.workspaceFolder = {
        uri = rd,
        name = vim.fn.fnamemodify(rd, ':t'),
      }

      -- flat config detection
      local flat_config_files = {}
      for _, file in ipairs(eslint_config_files) do
        if file:match('config') then
          flat_config_files[#flat_config_files + 1] = file
        end
      end

      for _, file in ipairs(flat_config_files) do
        local found_files = vim.fn.globpath(rd, file, true, true)

        local filtered = {}
        for _, f in ipairs(found_files) do
          if not f:find('[/\\]node_modules[/\\]') then
            filtered[#filtered + 1] = f
          end
        end

        if #filtered > 0 then
          config.settings.experimental = config.settings.experimental or {}
          config.settings.experimental.useFlatConfig = true
          break
        end
      end

      -- Yarn2 PnP support
      local pnp_cjs = rd .. '/.pnp.cjs'
      local pnp_js = rd .. '/.pnp.js'
      if type(config.cmd) == 'table' and (vim.uv.fs_stat(pnp_cjs) or vim.uv.fs_stat(pnp_js)) then
        config.cmd = vim.list_extend({ 'yarn', 'exec' }, config.cmd)
      end
    end,

    handlers = {
      ['eslint/openDoc'] = function(_, result)
        if result then
          vim.ui.open(result.url)
        end
        return {}
      end,
      ['eslint/confirmESLintExecution'] = function(_, result)
        if not result then
          return
        end
        return 4
      end,
      ['eslint/probeFailed'] = function()
        vim.notify('[lsp] ESLint probe failed.', vim.log.levels.WARN)
        return {}
      end,
      ['eslint/noLibrary'] = function()
        vim.notify('[lsp] Unable to find ESLint library.', vim.log.levels.WARN)
        return {}
      end,
    },
  }
end

return M
