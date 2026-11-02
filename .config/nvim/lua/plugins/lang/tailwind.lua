return {
  -- Tailwind LS registers workspace/didChangeWatchedFiles once per Tailwind
  -- workspace (28+ in this monorepo); Neovim then spawns a recursive
  -- inotifywait per registration, exhausting the inotify watch limit.
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tailwindcss = {
          capabilities = {
            workspace = {
              didChangeWatchedFiles = { dynamicRegistration = false },
            },
          },
        },
      },
    },
  },
}
