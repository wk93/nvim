vim.loader.enable()

local cmd = vim.cmd
local opt = vim.o

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

opt.number = true
opt.relativenumber = true

opt.cursorline = true

opt.expandtab = true
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2

vim.cmd.colorscheme("rose-pine")

-- Native plugins
cmd.filetype('plugin', 'indent', 'on')
cmd.packadd('cfilter') -- Allows filtering the quickfix list with :cfdo

-- let sqlite.lua (which some plugins depend on) know where to find sqlite
vim.g.sqlite_clib_path = require('luv').os_getenv('LIBSQLITE')
