return {
  "stevearc/conform.nvim",
  opts = {
    formatters = {
      black = {
        command = "black",
        args = {
          "--preview",
          "--line-length=100",
          "-",
        },
        stdin = true,
      },
    },
  },
}
