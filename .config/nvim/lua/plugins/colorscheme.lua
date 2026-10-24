return {
  "maxmx03/solarized.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    vim.o.termguicolors = true
    vim.opt.background = "light"
    require("solarized").setup({})
    vim.cmd.colorscheme("solarized")

    -- solarized.nvim gives `DiffAdd` only a foreground colour (no background
    -- block) while `DiffDelete`/`DiffText` use `reverse`, so added lines look
    -- unhighlighted in every diff view (Diffview, fugitive, gitsigns, ...).
    -- Force solid backgrounds so additions/deletions read like GitHub.
    local function diff_highlights()
      if vim.o.background == "dark" then
        vim.api.nvim_set_hl(0, "DiffAdd", { bg = "#2f4a1f", fg = "#c9e88a" })
        vim.api.nvim_set_hl(0, "DiffChange", { bg = "#4a3f1f" })
        vim.api.nvim_set_hl(0, "DiffDelete", { bg = "#5a2a2a", fg = "#f3a6a0" })
        vim.api.nvim_set_hl(0, "DiffText", { bg = "#3f6b2f", fg = "#eaffd0", bold = true })
      else
        vim.api.nvim_set_hl(0, "DiffAdd", { bg = "#d7e4b0" })
        vim.api.nvim_set_hl(0, "DiffChange", { bg = "#f4e3a8" })
        vim.api.nvim_set_hl(0, "DiffDelete", { bg = "#f3c2ba", fg = "#9c2b26" })
        vim.api.nvim_set_hl(0, "DiffText", { bg = "#b6d97a", bold = true })
      end
    end

    vim.api.nvim_create_autocmd("ColorScheme", { callback = diff_highlights })
    diff_highlights()
  end,
}
