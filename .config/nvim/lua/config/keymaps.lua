-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- Ctrl+Left/Right jump by word in normal mode instead of resizing windows.
map("n", "<C-Left>", "b", { noremap = true, silent = true, desc = "Word backward" })
map("n", "<C-Right>", "w", { noremap = true, silent = true, desc = "Word forward" })

-- Window navigation with Ctrl+Shift+Arrows.
map("n", "<C-S-Up>", "<C-w>k", { noremap = true, silent = true, desc = "Window up" })
map("n", "<C-S-Down>", "<C-w>j", { noremap = true, silent = true, desc = "Window down" })
map("n", "<C-S-Left>", "<C-w>h", { noremap = true, silent = true, desc = "Window left" })
map("n", "<C-S-Right>", "<C-w>l", { noremap = true, silent = true, desc = "Window right" })

-- Scroll the viewport without moving the cursor.
map("n", "<S-Up>", "<C-y>", { noremap = true, silent = true, desc = "Scroll up one line" })
map("n", "<S-Down>", "<C-e>", { noremap = true, silent = true, desc = "Scroll down one line" })

-- Cycle buffers with Shift+Arrows and reorder them with Alt+,/..
map("n", "<S-Left>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Previous buffer" })
map("n", "<S-Right>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
map("n", "<A-,>", "<cmd>BufferLineMovePrev<cr>", { silent = true, desc = "Move buffer left" })
map("n", "<A-.>", "<cmd>BufferLineMoveNext<cr>", { silent = true, desc = "Move buffer right" })

-- Close every open buffer while keeping the current window usable.
map("n", "<leader>ba", function()
  Snacks.bufdelete.all()
end, { desc = "Delete all buffers" })

-- Temporarily resize windows with arrows or hjkl; Esc or leaving the buffer exits.
local resize_group = vim.api.nvim_create_augroup("ResizeMode", { clear = true })
local resize_buf
local resize_keys = {
  ["<Left>"] = { ":vertical resize -2<CR>", "Shrink width" },
  ["<Right>"] = { ":vertical resize +2<CR>", "Grow width" },
  ["<Up>"] = { ":resize -2<CR>", "Shrink height" },
  ["<Down>"] = { ":resize +2<CR>", "Grow height" },
  h = { ":vertical resize -2<CR>", "Shrink width" },
  l = { ":vertical resize +2<CR>", "Grow width" },
  k = { ":resize -2<CR>", "Shrink height" },
  j = { ":resize +2<CR>", "Grow height" },
}

local function exit_resize_mode()
  if not resize_buf then
    return
  end
  local buf = resize_buf
  resize_buf = nil
  for lhs in pairs(resize_keys) do
    pcall(vim.keymap.del, "n", lhs, { buffer = buf })
  end
  pcall(vim.keymap.del, "n", "<Esc>", { buffer = buf })
  if vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_clear_autocmds({ group = resize_group, buffer = buf })
  end
end

local function enter_resize_mode()
  if resize_buf then
    exit_resize_mode()
    return
  end
  local buf = vim.api.nvim_get_current_buf()
  resize_buf = buf
  for lhs, spec in pairs(resize_keys) do
    map("n", lhs, spec[1], { buffer = buf, silent = true, desc = spec[2] })
  end
  map("n", "<Esc>", exit_resize_mode, { buffer = buf, silent = true, desc = "Exit resize mode" })
  vim.api.nvim_create_autocmd("BufLeave", {
    group = resize_group,
    buffer = buf,
    once = true,
    callback = exit_resize_mode,
  })
  vim.notify("Resize mode: arrows/hjkl resize, <Esc> to exit", vim.log.levels.INFO)
end

map("n", "<leader>wr", enter_resize_mode, { desc = "Window resize mode" })

-- Open this file's version from the first available default branch in a vsplit.
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

  local result, branch_name
  for _, branch in ipairs({ "master", "main", "trunk" }) do
    local candidate = vim.system({ "git", "show", branch .. ":" .. relative_path }, { cwd = git_root, text = true }):wait()
    if candidate.code == 0 then
      result, branch_name = candidate, branch
      break
    end
  end
  if not result then
    vim.notify("File does not exist at master/main/trunk", vim.log.levels.WARN)
    return
  end

  vim.cmd("vsplit")
  local buf = vim.api.nvim_create_buf(false, true)
  local lines = vim.split(result.stdout or "", "\n", { plain = true })
  if lines[#lines] == "" then
    table.remove(lines)
  end
  vim.api.nvim_win_set_buf(0, buf)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_name(buf, string.format("%s [%s]", relative_path, string.upper(branch_name)))
  vim.bo[buf].filetype = filetype
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = false
  vim.bo[buf].readonly = true
end

map("n", "<leader>gm", open_file_from_head, { desc = "Open current file from main branch" })

-- Send a visual selection to the herdr agent in this workspace and focus it.
local function send_selection_to_agent()
  local herdr = vim.env.HERDR_BIN_PATH
  if not herdr or herdr == "" then
    herdr = "herdr"
  end
  local pane = vim.env.HERDR_PANE_ID
  if not pane or pane == "" then
    vim.notify("herdr: not in a herdr pane", vim.log.levels.WARN)
    return
  end

  local workspace = vim.fn.matchstr(pane, "^[^:]*")
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
  for _, agent in ipairs(data.result.agents) do
    if agent.workspace_id == workspace then
      target = agent.pane_id
      break
    end
  end
  if not target then
    vim.notify("herdr: no agent in workspace " .. workspace, vim.log.levels.WARN)
    return
  end

  local first, last = vim.fn.line("v"), vim.fn.line(".")
  vim.cmd('silent normal! "vy')
  local text = vim.fn.getreg("v")
  if text == "" then
    vim.notify("herdr: empty selection", vim.log.levels.WARN)
    return
  end
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
  local file = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":.")
  if file == "" then
    file = "[no name]"
  end
  text = string.format("Selection from %s:%d-%d:\n\n%s", file, math.min(first, last), math.max(first, last), text)
  text = text:gsub("[\r\n]+$", "")
  local result = vim.fn.system({ herdr, "pane", "send-text", target, text })
  if vim.v.shell_error ~= 0 then
    vim.notify("herdr: send failed: " .. result, vim.log.levels.ERROR)
    return
  end
  vim.fn.system({ herdr, "agent", "focus", target })
  vim.notify("sent selection to agent", vim.log.levels.INFO)
end

map("x", "<leader>y", send_selection_to_agent, { desc = "Send selection to herdr agent" })
