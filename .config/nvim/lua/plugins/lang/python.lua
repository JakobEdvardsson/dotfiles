return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local console_datastore_extra_paths = { "lib", "migrations", "../../bin" }

      opts.servers.basedpyright = {
        before_init = function(_, config)
          if config.root_dir and config.root_dir:match("/components/console%-datastore$") then
            config.settings = vim.tbl_deep_extend("force", config.settings or {}, {
              basedpyright = {
                analysis = {
                  extraPaths = console_datastore_extra_paths,
                },
              },
            })
          end
        end,
        settings = {
          basedpyright = {
            -- analysis = {
            --   autoSearchPaths = true,
            --   useLibraryCodeForTypes = true,
            --   typeCheckingMode = "strict",
            -- },
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
