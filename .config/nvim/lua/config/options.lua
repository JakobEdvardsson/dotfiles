-- Options are automatically loaded before lazy.nvim startup.
require("config.remote_clipboard").setup()

vim.opt.relativenumber = false
vim.g.autoformat = false

-- Use basedpyright for Python and keep more context above/below the cursor.
vim.g.lazyvim_python_lsp = "basedpyright"
vim.opt.scrolloff = 15
