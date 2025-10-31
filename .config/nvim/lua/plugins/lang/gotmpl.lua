vim.filetype.add({
  extension = {
    gotmpl = "gotmpl",
    tmpl = "gotmpl",
    m4 = "gotmpl",
  },
})
return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "mason-org/mason-lspconfig.nvim",
        dependencies = { "mason-org/mason.nvim" },
        opts = function(_, opts)
          opts.ensure_installed = opts.ensure_installed or {}
          vim.list_extend(opts.ensure_installed, {
            "gopls",
          })
        end,
      },
    },
    opts = {
      servers = {
        ---@type vim.lsp.Config
        gopls = {
          settings = {
            gopls = {
              templateExtensions = "gotmpl",
            },
          },
        },
      },
    },
    opts_extend = {
      "servers.gopls.settings.gopls.templateExtensions",
    },
  },
}
