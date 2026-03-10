return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        vtsls = {
          settings = {
            vtsls = {
              tsserver = {
                -- Avoid tsserver GC stalls in large TypeScript workspaces.
                maxTsServerMemory = 8192,
              },
              experimental = {
                completion = {
                  -- Keep completion payloads smaller and cheaper to rank/render.
                  entriesLimit = 25,
                  enableServerSideFuzzyMatch = false,
                },
              },
            },
            typescript = {
              suggest = {
                -- Skip broad symbol harvesting from imports/module exports.
                includeCompletionsForModuleExports = false,
                includeCompletionsForImportStatements = false,
              },
            },
            javascript = {
              suggest = {
                includeCompletionsForModuleExports = false,
                includeCompletionsForImportStatements = false,
              },
            },
          },
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
