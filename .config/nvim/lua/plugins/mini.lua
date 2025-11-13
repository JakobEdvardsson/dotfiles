return {
  "nvim-mini/mini.files",
  opts = {
    windows = {
      preview = true,
      width_focus = 50,
      width_preview = 50,
    },
    options = {
      -- Whether to use for editing directories
      -- Disabled by default in LazyVim because neo-tree is used for that
      use_as_default_explorer = true,
    },
    mappings = {
      go_in_horizontal = "<C-w>s",
      go_in_vertical = "<C-w>v",
      go_in_horizontal_plus = "<C-w>S",
      go_in_vertical_plus = "<C-w>V",
      toggle_hidden = "g.",
      change_cwd = "gp",
      go_in_plus = "<S-Right>",
      go_out_plus = "<S-Left>",
    },
  },
  keys = {
    {
      "-",
      function()
        local mini = require("mini.files")
        if not mini.close() then
          mini.open()
        end
      end,
      desc = "Toggle MiniFiles",
    },
    {
      "<CR>",
      function()
        require("mini.files").go_in({ close_on_file = true })
      end,
      desc = "MiniFiles Go In (Enter)",
    },
  },
}
