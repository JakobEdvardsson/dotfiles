-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- LSP Server to use for Python.
-- Set to "basedpyright" to use basedpyright instead of pyright.
vim.g.lazyvim_python_lsp = "basedpyright"
vim.g.root_spec = { "cwd" }

-- Disable eslint auto-format in UPX (type-aware eslint rules are heavy on save)
if vim.fn.getcwd() == "/home/jakobe/code/upx" then
  vim.g.lazyvim_eslint_auto_format = false
end

vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.scrolloff = 15
