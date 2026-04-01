-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

for _, key in ipairs({
  "[b",
  "]b",
  "<leader><tab>l",
  "<leader><tab>h",
  "<leader><tab>o",
  "<leader><tab>d",
  "<leader><tab>f",
  "<leader><tab><tab>",
}) do
  pcall(vim.keymap.del, "n", key)
end

local function open_file_from_head()
  local file = vim.api.nvim_buf_get_name(0)
  local filetype = vim.bo.filetype
  if file == "" then
    vim.notify("Current buffer has no file on disk", vim.log.levels.WARN)
    return
  end

  local file_dir = vim.fs.dirname(file)
  local git_root_result = vim.system({ "git", "rev-parse", "--show-toplevel" }, { cwd = file_dir }):wait()
  if git_root_result.code ~= 0 then
    vim.notify("Current file is not in a Git repository", vim.log.levels.WARN)
    return
  end

  local git_root = vim.trim(git_root_result.stdout or "")
  local relative_path = vim.fs.relpath(git_root, file)
  if not relative_path then
    vim.notify("Failed to resolve file path relative to Git root", vim.log.levels.ERROR)
    return
  end

  local head_file_result = vim.system({ "git", "show", "HEAD:" .. relative_path }, { cwd = git_root, text = true }):wait()
  if head_file_result.code ~= 0 then
    vim.notify("File does not exist at HEAD", vim.log.levels.WARN)
    return
  end

  vim.cmd("vsplit")

  local head_buf = vim.api.nvim_create_buf(false, true)
  local lines = vim.split(head_file_result.stdout or "", "\n", { plain = true })
  if lines[#lines] == "" then
    table.remove(lines, #lines)
  end

  vim.api.nvim_win_set_buf(0, head_buf)
  vim.api.nvim_buf_set_lines(head_buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_name(head_buf, string.format("%s [HEAD]", relative_path))
  vim.bo[head_buf].filetype = filetype
  vim.bo[head_buf].buftype = "nofile"
  vim.bo[head_buf].bufhidden = "wipe"
  vim.bo[head_buf].swapfile = false
  vim.bo[head_buf].modifiable = false
  vim.bo[head_buf].readonly = true
end

-- Move to window
for _, key in ipairs({ "<C-Up>", "<C-Down>", "<C-Left>", "<C-Right>" }) do
  pcall(vim.keymap.del, "n", key)
end
map("n", "<C-Left>", "<C-w>h", { noremap = true, silent = true })
map("n", "<C-Down>", "<C-w>j", { noremap = true, silent = true })
map("n", "<C-Up>", "<C-w>k", { noremap = true, silent = true })
map("n", "<C-Right>", "<C-w>l", { noremap = true, silent = true })

map("n", "<C-S-Up>", ":resize +2<CR>", { noremap = true, silent = true })
map("n", "<C-S-Down>", ":resize -2<CR>", { noremap = true, silent = true })
map("n", "<C-S-Left>", ":vertical resize -2<CR>", { noremap = true, silent = true })
map("n", "<C-S-Right>", ":vertical resize +2<CR>", { noremap = true, silent = true })

map("n", "<S-Down>", "<C-e>", { noremap = true, silent = true, desc = "Scroll down one line without moving cursor" })
map("n", "<S-Up>", "<C-y>", { noremap = true, silent = true, desc = "Scroll up one line without moving cursor" })

-- buffers
map("n", "<S-Left>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "<S-Right>", "<cmd>bnext<cr>", { desc = "Next Buffer" })

map("n", "<A-.>", "<cmd>BufferLineMoveNext<CR>", { silent = true })
map("n", "<A-,>", "<cmd>BufferLineMovePrev<CR>", { silent = true })
map("n", "<S-Left>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev Buffer" })
map("n", "<S-Right>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next Buffer" })

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

local function goto_next_diag()
  local opts = error_only and { severity = vim.diagnostic.severity.ERROR } or {}
  opts.forward = true
  opts.count = 1
  vim.diagnostic.jump(opts)
end

local function goto_prev_diag()
  local opts = error_only and { severity = vim.diagnostic.severity.ERROR } or {}
  opts.forward = false
  opts.count = 1
  vim.diagnostic.jump(opts)
end

vim.keymap.set("n", "]d", goto_next_diag)
vim.keymap.set("n", "[d", goto_prev_diag)

map("n", "<leader>tn", "<cmd>tabnext<cr>", { desc = "Next Tab" })
map("n", "<leader>tp", "<cmd>tabprevious<cr>", { desc = "Prev Tab" })
map("n", "<leader>tt", "<cmd>tabnew<cr>", { desc = "New Tab" })
map("n", "<leader>td", "<cmd>tabclose<cr>", { desc = "Close Tab" })
map("n", "<leader>to", "<cmd>tabonly<cr>", { desc = "Close Other Tabs" })
map("n", "<leader>tf", "<cmd>tabfirst<cr>", { desc = "First Tab" })

vim.keymap.set("n", "<leader>xe", function()
  error_only = not error_only
  if error_only then
    vim.cmd("DiagSeverity ERROR")
  else
    vim.cmd("DiagSeverity INFO")
  end
end, { desc = "Toggle diagnostics error-only / all" })

map("n", "<leader>gH", open_file_from_head, { desc = "Open current file from HEAD" })
