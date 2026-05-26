-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- LSP Server to use for Python.
-- Set to "basedpyright" to use basedpyright instead of pyright.
vim.g.lazyvim_python_lsp = "basedpyright"

if vim.fn.getcwd():match("^/home/jakobe/code/upx") then
  vim.g.lazyvim_eslint_auto_format = false
  -- LazyVim defaults updatetime to 200ms — CursorHold fires 5x/sec, triggering
  -- diagnostics, inlay hints, document highlights, and lspsaga's symbol winbar
  -- on every pause. Match VS Code's ~1s debounce instead.
  vim.opt.updatetime = 1200
end

vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.scrolloff = 15
