-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- Move to window tmux support
for _, key in ipairs({ "<C-Up>", "<C-Down>", "<C-Left>", "<C-Right>" }) do
  vim.keymap.del({ "n" }, key)
end
map("n", "<C-Left>", ":<C-U>TmuxNavigateLeft<cr>", { noremap = true, silent = true })
map("n", "<C-Down>", ":<C-U>TmuxNavigateDown<cr>", { noremap = true, silent = true })
map("n", "<C-Up>", ":<C-U>TmuxNavigateUp<cr>", { noremap = true, silent = true })
map("n", "<C-Right>", ":<C-U>TmuxNavigateRight<cr>", { noremap = true, silent = true })

-- buffers
map("n", "<S-Left>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "<S-Right>", "<cmd>bnext<cr>", { desc = "Next Buffer" })

-- substitute
map("n", "s", require("substitute").operator, { noremap = true })
map("n", "ss", require("substitute").line, { noremap = true })
map("n", "S", require("substitute").eol, { noremap = true })
map("x", "s", require("substitute").visual, { noremap = true })

-- Terminal Mappings
map("t", "<C-\\>", "<cmd>close<cr>", { desc = "Hide Terminal" })
