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
}
