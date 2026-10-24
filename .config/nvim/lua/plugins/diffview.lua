-- Diffview.nvim: a single-tabpage side-by-side diff viewer for any git rev.
-- We use dlyongemallo's fork of sindrets/diffview.nvim because it adds the
-- local "reviewed" feature we want (file selection + hide-reviewed).
-- https://github.com/dlyongemallo/diffview.nvim
--
-- In the file panel:  w = toggle reviewed, C = clear all, H = hide/reveal
-- reviewed files. `persist_selections` keeps them across restarts.
--
-- This file also wires up a GitHub PR review workflow (`:DiffviewPR`) on top of
-- the `gh` CLI, plus a "my branch vs origin/HEAD" shortcut.
--
-- Keymaps live under `<leader>gv` ("git diffview"). The other `<leader>g*`
-- keys are already taken: LazyVim's snacks picker owns <leader>gd/gs/gD/gS,
-- gitsigns owns <leader>gh, the gh extra owns <leader>G*, etc.

local function run(cmd)
  return vim.system(cmd, { text = true }):wait()
end

---Resolve a PR number: the explicit argument, or the PR of the current branch.
---@param arg? string
---@return string?
local function resolve_pr(arg)
  if arg and arg ~= "" then
    return arg
  end
  local res = run({ "gh", "pr", "view", "--json", "number", "-q", ".number" })
  if res.code ~= 0 then
    return nil
  end
  local n = vim.trim(res.stdout or "")
  return n ~= "" and n or nil
end

---Fetch a PR's base branch and head into local refs (working tree untouched)
---and return a triple-dot rev range: a merge-base comparison, i.e. exactly
---what GitHub shows in the "Files changed" tab.
---@param n string
---@return string? range, string? err
local function pr_range(n)
  local res = run({ "gh", "pr", "view", n, "--json", "baseRefName" })
  if res.code ~= 0 then
    return nil, vim.trim(res.stderr or "`gh pr view` failed")
  end
  local ok, data = pcall(vim.json.decode, res.stdout or "")
  if not ok or type(data) ~= "table" or not data.baseRefName then
    return nil, "could not parse `gh pr view` output"
  end

  local pr_ref = ("refs/remotes/origin/pr/%s"):format(n)

  local base = run({ "git", "fetch", "origin", data.baseRefName })
  if base.code ~= 0 then
    return nil, vim.trim(base.stderr or "git fetch of base branch failed")
  end

  -- The leading `+` forces the update: PR branches are often force-pushed, and
  -- without it `git fetch` rejects a non-fast-forward move of the local ref.
  local head = run({ "git", "fetch", "origin", ("+pull/%s/head:%s"):format(n, pr_ref) })
  if head.code ~= 0 then
    return nil, vim.trim(head.stderr or "git fetch of PR head failed")
  end

  return ("origin/%s...%s"):format(data.baseRefName, pr_ref)
end

---@param n? string
---@param commits? boolean show commit-by-commit instead of the aggregate diff
local function open_pr(n, commits)
  n = resolve_pr(n)
  if not n then
    vim.notify("DiffviewPR: no PR for the current branch (pass a PR number)", vim.log.levels.ERROR)
    return
  end

  local range, err = pr_range(n)
  if not range then
    vim.notify("DiffviewPR: " .. err, vim.log.levels.ERROR)
    return
  end

  if commits then
    vim.cmd(("DiffviewFileHistory --range=%s --right-only --no-merges"):format(range))
  else
    vim.cmd(("DiffviewOpen %s"):format(range))
  end
end

---Diff the current branch against its merge-base with origin/HEAD. This is the
---"review my own PR branch" flow; --imply-local keeps the working-tree files on
---the right so LSP still works.
local function open_branch()
  local head = run({ "git", "rev-parse", "--verify", "--quiet", "refs/remotes/origin/HEAD" })
  if head.code ~= 0 then
    vim.notify("No origin/HEAD ref; run: git remote set-head -a origin", vim.log.levels.WARN)
    return
  end
  vim.cmd("DiffviewOpen origin/HEAD...HEAD --imply-local")
end

local function file_history()
  local file = vim.fn.expand("%")
  vim.cmd("DiffviewFileHistory " .. vim.fn.fnameescape(file))
end

return {
  {
    "dlyongemallo/diffview.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
      "DiffviewRefresh",
      "DiffviewLog",
      "DiffviewFileHistory",
      "DiffviewPR",
      "DiffviewPRCommits",
    },
    keys = {
      { "<leader>gv", group = "git diffview" },
      { "<leader>gvo", "<cmd>DiffviewOpen<cr>", desc = "Working tree diff" },
      { "<leader>gvb", open_branch, desc = "Branch vs origin/HEAD" },
      { "<leader>gvp", function() open_pr(nil, false) end, desc = "GitHub PR diff" },
      { "<leader>gvP", function() open_pr(nil, true) end, desc = "GitHub PR commits" },
      { "<leader>gvf", file_history, desc = "File history" },
      { "<leader>gvF", "<cmd>DiffviewFileHistory<cr>", desc = "Repo history" },
      { "<leader>gvt", "<cmd>DiffviewToggleFiles<cr>", desc = "Toggle file panel" },
      { "<leader>gvc", "<cmd>DiffviewClose<cr>", desc = "Close" },
    },
    opts = {
      enhanced_diff_hl = true,
      -- Local "reviewed" tracking (fork feature): remember selections + the
      -- hide-reviewed state per repo/rev, and always show the ■/□ marks.
      persist_selections = { enabled = true },
      always_show_marks = true,
      view = {
        merge_tool = { layout = "diff3_mixed" },
      },
    },
    config = function(_, opts)
      require("diffview").setup(opts)

      vim.api.nvim_create_user_command("DiffviewPR", function(o)
        open_pr(o.args, false)
      end, { nargs = "?", desc = "Open a GitHub PR's diff in Diffview" })

      vim.api.nvim_create_user_command("DiffviewPRCommits", function(o)
        open_pr(o.args, true)
      end, { nargs = "?", desc = "Review a GitHub PR commit-by-commit in Diffview" })
    end,
  },
}
