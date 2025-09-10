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

-- Command to set diagnostic severity dynamically
vim.api.nvim_create_user_command("DiagSeverity", function(opts)
  local map = {
    ERROR = { vim.diagnostic.severity.ERROR },
    WARN = { vim.diagnostic.severity.WARN, vim.diagnostic.severity.ERROR },
    INFO = { vim.diagnostic.severity.INFO, vim.diagnostic.severity.WARN, vim.diagnostic.severity.ERROR },
    ALL = {
      vim.diagnostic.severity.HINT,
      vim.diagnostic.severity.INFO,
      vim.diagnostic.severity.WARN,
      vim.diagnostic.severity.ERROR,
    },
  }

  local sevs = map[opts.args:upper()]
  if not sevs then
    print("Invalid severity. Options: ERROR, WARN, INFO, ALL")
    return
  end

  vim.diagnostic.config({
    virtual_text = { severity = { min = sevs[1] } },
    signs = { severity = { min = sevs[1] } },
    underline = { severity = { min = sevs[1] } },
  })

  print("Diagnostics set to show: " .. opts.args)
end, {
  nargs = 1,
  complete = function()
    return { "ERROR", "WARN", "INFO", "ALL" }
  end,
})
-- Toggle between showing only errors and showing all diagnostics
local error_only = false

vim.keymap.set("n", "<leader>xe", function()
  error_only = not error_only
  if error_only then
    vim.cmd("DiagSeverity ERROR")
  else
    vim.cmd("DiagSeverity ALL")
  end
end, { desc = "Toggle diagnostics error-only / all" })
