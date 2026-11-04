local function git_root()
  return LazyVim.root.git() or LazyVim.root()
end

return {
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader><space>", function() Snacks.picker.files({ cwd = git_root() }) end, desc = "Find Files (Git Root)" },
      { "<leader>ff", function() Snacks.picker.files({ cwd = git_root() }) end, desc = "Find Files (Git Root)" },
      { "<leader>/", function() Snacks.picker.grep({ cwd = git_root() }) end, desc = "Grep (Git Root)" },
      { "<leader>sg", function() Snacks.picker.grep({ cwd = git_root() }) end, desc = "Grep (Git Root)" },
      { "<leader>fg", function() Snacks.picker.git_files({ cwd = git_root() }) end, desc = "Find Files (git-files, Git Root)" },
    },
  },
}
