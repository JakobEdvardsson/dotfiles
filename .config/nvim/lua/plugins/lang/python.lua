return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local function console_datastore_root(root)
        -- lspconfig typically resolves root_dir to the git root (e.g. the
        -- worktree root), not the component dir, so accept both.
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
        return nil
      end

      local function console_datastore_extra_paths(cd_root)
        -- git/worktree root is two levels up from components/console-datastore
        local repo_root = cd_root:match("(.*)/components/console%-datastore$")
          or vim.fn.fnamemodify(cd_root, ":h:h")
        return {
          cd_root .. "/lib",
          cd_root .. "/migrations",
          cd_root .. "/bin",
          repo_root .. "/bin",
        }
      end

      opts.servers.basedpyright = {
        before_init = function(_, config)
          local cd_root = console_datastore_root(config.root_dir)
          if cd_root then
            config.settings = vim.tbl_deep_extend("force", config.settings or {}, {
              basedpyright = {
                analysis = {
                  extraPaths = console_datastore_extra_paths(cd_root),
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
