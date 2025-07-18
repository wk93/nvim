vim.loader.enable()

local cmd = vim.cmd
local opt = vim.o

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Native plugins
cmd.filetype('plugin', 'indent', 'on')
cmd.packadd('cfilter') -- Allows filtering the quickfix list with :cfdo

-- let sqlite.lua (which some plugins depend on) know where to find sqlite
vim.g.sqlite_clib_path = require('luv').os_getenv('LIBSQLITE')
