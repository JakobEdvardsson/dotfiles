return {
  "shaunsingh/solarized.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    vim.opt.background = "light"
    vim.cmd.colorscheme("solarized")

    local function improve_string_contrast()
      local string_highlights = {
        "String",
        "@string",
        "@string.python",
        "@string.special",
        "@string.escape",
      }
      for _, group in ipairs(string_highlights) do
        vim.api.nvim_set_hl(0, group, { fg = "#586e75" })
      end
      vim.api.nvim_set_hl(0, "SnacksPickerSearch", { fg = "#657b83", bg = "#eee8d5", bold = true })
      vim.api.nvim_set_hl(0, "SnacksPickerMatch", { fg = "#dc322f", bold = true })
    end

    improve_string_contrast()
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = improve_string_contrast,
    })
  end,
}
