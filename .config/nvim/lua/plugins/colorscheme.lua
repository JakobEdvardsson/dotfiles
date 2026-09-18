return {
  "maxmx03/solarized.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    vim.o.termguicolors = true
    vim.opt.background = "light"
    require("solarized").setup({})
    vim.cmd.colorscheme("solarized")
  end,
}
