return {
  {
    "tiagovla/scope.nvim",
    config = function()
      require("scope").setup({})
    end,
  },

  {
    "akinsho/bufferline.nvim",
    dependencies = { "tiagovla/scope.nvim" },
    opts = function(_, opts)
      opts.options = opts.options or {}
      opts.options.always_show_bufferline = true
    end,
  },
}
