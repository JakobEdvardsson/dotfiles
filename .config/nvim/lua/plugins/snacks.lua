return {
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader>s", function() Snacks.scratch() end, desc = "Scratch" },
    },
    opts = function(_, opts)
      opts = opts or {}
      opts.scratch = vim.tbl_deep_extend("force", opts.scratch or {}, {
        ft = "markdown",
        file = vim.fn.stdpath("data") .. "/scratch/scratch.md",
      })

      opts.lazygit = vim.tbl_deep_extend("force", opts.lazygit or {}, {
        config = {
          os = {
            editPreset = "",
            edit = [[nvim --server "$NVIM" --remote-send "<C-\><C-N>:lua local w=vim.api.nvim_get_current_win();local c=vim.api.nvim_win_get_config(w);if c.relative~='' then vim.api.nvim_win_close(w,true) end<CR>:drop {{filename}}<CR>"]],
            editAtLine = [[nvim --server "$NVIM" --remote-send "<C-\><C-N>:lua local w=vim.api.nvim_get_current_win();local c=vim.api.nvim_win_get_config(w);if c.relative~='' then vim.api.nvim_win_close(w,true) end<CR>:drop {{filename}}<CR>:{{line}}<CR>zz"]],
            editAtLineAndWait = [[nvim --server "$NVIM" --remote-send "<C-\><C-N>:lua local w=vim.api.nvim_get_current_win();local c=vim.api.nvim_win_get_config(w);if c.relative~='' then vim.api.nvim_win_close(w,true) end<CR>:drop {{filename}}<CR>:{{line}}<CR>zz"]],
            editInTerminal = false,
          },
        },
      })

      return opts
    end,
  },
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>s", desc = "Scratch" },
      },
    },
  },
}
