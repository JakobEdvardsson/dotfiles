-- Options are automatically loaded before lazy.nvim startup.
require("config.remote_clipboard").setup()

vim.opt.relativenumber = false
vim.g.autoformat = false

-- Prefer the git root over an LSP root so file search and grep cover the whole
-- repository, as they did when Neovim was started at the repo root on Fedora.
vim.g.root_spec = { { ".git" }, "lsp", "cwd" }

-- Use basedpyright for Python and keep more context above/below the cursor.
vim.g.lazyvim_python_lsp = "basedpyright"
vim.opt.scrolloff = 15
