return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- opts.servers.ruff = {
      --   init_options = {
      --     settings = {
      --       lineLength = 100,
      --     },
      --   },
      -- }

      opts.servers.basedpyright = {
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              typeCheckingMode = "basic",
            },
            disableOrganizeImports = true,
          },
        },
      }
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        python = { "ruff_fix", "ruff_format" },
      },
    },
  },
}
