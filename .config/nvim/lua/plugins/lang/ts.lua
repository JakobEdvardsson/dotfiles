return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        vtsls = {
          cmd = { "pnpm", "exec", "vtsls", "--stdio" },
          settings = {
            vtsls = {
              autoUseWorkspaceTsdk = true,
              tsserver = {
                maxTsServerMemory = 8192,
              },
              experimental = {
                completion = {
                  entriesLimit = 25,
                  enableServerSideFuzzyMatch = false,
                },
              },
            },
            typescript = {
              suggest = {
                includeCompletionsForModuleExports = false,
                includeCompletionsForImportStatements = false,
              },
              preferences = {
                preferGoToSourceDefinition = true,
              },
            },
            javascript = {
              suggest = {
                includeCompletionsForModuleExports = false,
                includeCompletionsForImportStatements = false,
              },
              preferences = {
                preferGoToSourceDefinition = true,
              },
            },
          },
        },
        oxlint = {
          cmd = { "pnpm", "exec", "oxlint", "--lsp" },
        },
        eslint = {
          condition = function(ctx)
            return not (ctx.root_dir or ""):match("/upx/")
          end,
        },
        tailwindcss = {
          condition = function(ctx)
            return not (ctx.root_dir or ""):match("/upx/")
          end,
        },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.default_format_opts = opts.default_format_opts or {}
      opts.default_format_opts.async = true

      opts.formatters = opts.formatters or {}
      opts.formatters.oxfmt = {
        command = "pnpm",
        args = { "exec", "oxfmt", "--stdin-filepath", "$FILENAME" },
        stdin = true,
      }

      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.javascript = { "oxfmt" }
      opts.formatters_by_ft.javascriptreact = { "oxfmt" }
      opts.formatters_by_ft.typescript = { "oxfmt" }
      opts.formatters_by_ft.typescriptreact = { "oxfmt" }
    end,
  },
}
