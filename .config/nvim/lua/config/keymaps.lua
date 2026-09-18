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

  local branch_result, branch_name
  for _, branch in ipairs({ "master", "main", "trunk" }) do
    local result = vim.system({ "git", "show", branch .. ":" .. relative_path }, { cwd = git_root, text = true }):wait()
    if result.code == 0 then
      branch_result = result
      branch_name = branch
      break
    end
  end
  if not branch_result then
    vim.notify("File does not exist at master/main/trunk", vim.log.levels.WARN)
    return
  end

  vim.cmd("vsplit")

  local head_buf = vim.api.nvim_create_buf(false, true)
  local lines = vim.split(branch_result.stdout or "", "\n", { plain = true })
  if lines[#lines] == "" then
    table.remove(lines, #lines)
  end

  vim.api.nvim_win_set_buf(0, head_buf)
  vim.api.nvim_buf_set_lines(head_buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_name(head_buf, string.format("%s [%s]", relative_path, string.upper(branch_name)))
  vim.bo[head_buf].filetype = filetype
  vim.bo[head_buf].buftype = "nofile"
  vim.bo[head_buf].bufhidden = "wipe"
  vim.bo[head_buf].swapfile = false
  vim.bo[head_buf].modifiable = false
  vim.bo[head_buf].readonly = true
end

for _, key in ipairs({ "<C-Up>", "<C-Down>", "<C-Left>", "<C-Right>" }) do
  pcall(vim.keymap.del, "n", key)
end
-- Ctrl+Left/Right: jump words, like the shell (insert mode does this natively).
map("n", "<C-Left>", "b", { noremap = true, silent = true })
map("n", "<C-Right>", "w", { noremap = true, silent = true })

-- Reviewr-style: select code, press "<leader>sa". It pastes the selection into the
-- agent's input and jumps focus to the agent so you can add context and press
-- Enter. Non-leader key to avoid clashing with LazyVim's <leader>s search group.
local function send_selection_to_agent()
  local herdr = vim.env.HERDR_BIN_PATH
  if herdr == nil or herdr == "" then
    herdr = "herdr"
  end
  local pane = vim.env.HERDR_PANE_ID
  if not pane or pane == "" then
    vim.notify("herdr: not in a herdr pane", vim.log.levels.WARN)
    return
  end
  local ws = vim.fn.matchstr(pane, "^[^:]*")
  local out = vim.fn.system({ herdr, "agent", "list" })
  if vim.v.shell_error ~= 0 then
    vim.notify("herdr: agent list failed: " .. out, vim.log.levels.ERROR)
    return
  end
  local ok, data = pcall(vim.fn.json_decode, out)
  if not ok or not data or not data.result or not data.result.agents then
    vim.notify("herdr: could not parse agent list", vim.log.levels.ERROR)
    return
  end
  local target
  for _, a in ipairs(data.result.agents) do
    if a.workspace_id == ws then
      target = a.pane_id
      break
    end
  end
  if not target then
    vim.notify("herdr: no agent in workspace " .. ws, vim.log.levels.WARN)
    return
  end
  local l1, l2 = vim.fn.line("v"), vim.fn.line(".") -- selection ends, capture before leaving visual mode
  vim.cmd('silent normal! "vy') -- yank selection into register v
  local text = vim.fn.getreg("v")
  if text == nil or text == "" then
    vim.notify("herdr: empty selection", vim.log.levels.WARN)
    return
  end
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false) -- leave visual mode
  local file = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":.")
  if file == "" then
    file = "[no name]"
  end
  text = string.format("Selection from %s:%d-%d:\n\n%s", file, math.min(l1, l2), math.max(l1, l2), text)
  text = text:gsub("[\r\n]+$", "") -- don't let a trailing newline submit it
  local res = vim.fn.system({ herdr, "pane", "send-text", target, text })
  if vim.v.shell_error ~= 0 then
    vim.notify("herdr: send failed: " .. res, vim.log.levels.ERROR)
    return
  end
  vim.fn.system({ herdr, "agent", "focus", target }) -- jump to the agent
  vim.notify("sent selection to agent", vim.log.levels.INFO)
end
map("v", "<leader>sa", send_selection_to_agent, { desc = "Send selection to agent and focus it" })

map("n", "<C-S-Up>", ":resize +2<CR>", { noremap = true, silent = true })
map("n", "<C-S-Down>", ":resize -2<CR>", { noremap = true, silent = true })
map("n", "<C-S-Left>", ":vertical resize -2<CR>", { noremap = true, silent = true })
map("n", "<C-S-Right>", ":vertical resize +2<CR>", { noremap = true, silent = true })

map("n", "<S-Down>", "<C-e>", { noremap = true, silent = true, desc = "Scroll down one line without moving cursor" })
map("n", "<S-Up>", "<C-y>", { noremap = true, silent = true, desc = "Scroll up one line without moving cursor" })

-- buffers
map("n", "<leader>ba", function()
  Snacks.bufdelete.all()
end, { desc = "Delete All Buffers" })
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

-- git
map("x", "ga", function()
  require("gitsigns").stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
end, { desc = "Git add selection" })
map("n", "ga", function()
  require("gitsigns").stage_hunk({ vim.fn.line("."), vim.fn.line(".") })
end, { desc = "Git add current line" })

-- Jump between unstaged hunks (working tree vs index, i.e. not yet git added)
map("n", "]g", function()
  require("gitsigns").nav_hunk("next", { target = "unstaged" })
end, { desc = "Next unstaged git change" })
map("n", "[g", function()
  require("gitsigns").nav_hunk("prev", { target = "unstaged" })
end, { desc = "Previous unstaged git change" })

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

map("n", "<leader>gm", open_file_from_head, { desc = "Open current file from Master" })
