return {
  {
    "nvimdev/lspsaga.nvim",
    event = "LspAttach",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      ui = {
        border = "rounded",
      },
      lightbulb = {
        enable = false,
      },
      symbol_in_winbar = {
        enable = true,
      },
      finder = {
        default = "ref+imp",
        methods = {
          tyd = "textDocument/typeDefinition",
        },
      },
    },
    keys = {
      { "K", "<cmd>Lspsaga hover_doc<cr>", desc = "Hover Doc" },
      { "gd", "<cmd>Lspsaga peek_definition<cr>", desc = "Peek Definition" },
      { "gr", "<cmd>Lspsaga finder ref<cr>", desc = "References" },
      { "gI", "<cmd>Lspsaga finder imp<cr>", desc = "Implementation" },
      { "<leader>k", "<cmd>Lspsaga peek_type_definition<cr>", desc = "Peek Type Definition" },
      { "<leader>ca", "<cmd>Lspsaga code_action<cr>", mode = { "n", "x" }, desc = "Code Action" },
      { "<leader>cr", "<cmd>Lspsaga rename<cr>", desc = "Rename" },
      { "]d", "<cmd>Lspsaga diagnostic_jump_next<cr>", desc = "Next Diagnostic" },
      { "[d", "<cmd>Lspsaga diagnostic_jump_prev<cr>", desc = "Prev Diagnostic" },
    },
  },
}
