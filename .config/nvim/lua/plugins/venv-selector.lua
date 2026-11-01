return {
  "linux-cultist/venv-selector.nvim",
  -- Load Python environments on demand and activate the cached choice for Python files.
  cmd = "VenvSelect",
  ft = "python",
  opts = function(_, opts)
    opts.options = vim.tbl_deep_extend("force", opts.options or {}, {
      notify_user_on_venv_activation = true,
      debug = true,
    })
    return opts
  end,
  keys = {
    { "<leader>cv", "<cmd>VenvSelect<cr>", desc = "Select VirtualEnv", ft = "python" },
  },
}
