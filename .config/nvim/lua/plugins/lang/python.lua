return {
  -- Use project-specific import paths for basedpyright in console-datastore.
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}

      local function console_datastore_root(root)
        if not root or root == "" then
          return nil
        end
        if root:match("/components/console%-datastore$") then
          return root
        end
        local candidate = root .. "/components/console-datastore"
        if vim.fn.isdirectory(candidate) == 1 then
          return candidate
        end
      end

      local function console_datastore_extra_paths(root)
        local repo_root = root:match("(.*)/components/console%-datastore$") or vim.fn.fnamemodify(root, ":h:h")
        return {
          root .. "/lib",
          root .. "/migrations",
          root .. "/bin",
          repo_root .. "/bin",
        }
      end

      local server = opts.servers.basedpyright or {}
      local before_init = server.before_init
      server.enabled = true
      server.before_init = function(client, config)
        if before_init then
          before_init(client, config)
        end
        local root = console_datastore_root(config.root_dir)
        if root then
          config.settings = vim.tbl_deep_extend("force", config.settings or {}, {
            basedpyright = {
              analysis = { extraPaths = console_datastore_extra_paths(root) },
            },
          })
        end
      end
      server.settings = vim.tbl_deep_extend("force", server.settings or {}, {
        basedpyright = {
          disableOrganizeImports = true,
        },
      })
      opts.servers.basedpyright = server
    end,
  },
  -- Run Ruff's safe fixes before formatting Python files.
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        python = { "ruff_fix", "ruff_format" },
      },
    },
  },
}
