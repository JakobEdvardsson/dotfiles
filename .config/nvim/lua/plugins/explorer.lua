return {
  -- Use mini.files as the directory opener and a previewable file manager.
  {
    "nvim-mini/mini.files",
    opts = {
      windows = {
        preview = true,
        width_focus = 50,
        width_preview = 50,
      },
      options = {
        use_as_default_explorer = true,
      },
      mappings = {
        go_in_horizontal = "<C-w>s",
        go_in_vertical = "<C-w>v",
        go_in_horizontal_plus = "<C-w>S",
        go_in_vertical_plus = "<C-w>V",
        go_in_plus = "<S-Right>",
        go_out_plus = "<S-Left>",
        toggle_hidden = "g.",
        change_cwd = "gp",
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
        desc = "MiniFiles Go In",
      },
    },
  },
  -- Keep the Snacks tree explorer available as a separate root/cwd view.
  {
    "folke/snacks.nvim",
    opts = {
      explorer = {},
    },
    keys = {
      {
        "<leader>e",
        function()
          local picker = Snacks.picker.get({ source = "explorer" })[1]
          if not picker then
            Snacks.explorer({ cwd = LazyVim.root() })
          elseif picker:is_focused() then
            picker:close()
          else
            picker:focus()
          end
        end,
        desc = "Explorer Snacks (root dir)",
      },
      {
        "<leader>E",
        function()
          local picker = Snacks.picker.get({ source = "explorer" })[1]
          if not picker then
            Snacks.explorer()
          elseif picker:is_focused() then
            picker:close()
          else
            picker:focus()
          end
        end,
        desc = "Explorer Snacks (cwd)",
      },
    },
  },
}
