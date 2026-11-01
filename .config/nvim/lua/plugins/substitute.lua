return {
  "gbprod/substitute.nvim",
  opts = {},
  -- Replace text with the yanked text using an operator, line, EOL, or selection.
  keys = {
    { "s", function() require("substitute").operator() end, mode = "n", desc = "Substitute operator" },
    { "ss", function() require("substitute").line() end, mode = "n", desc = "Substitute line" },
    { "S", function() require("substitute").eol() end, mode = "n", desc = "Substitute to end of line" },
    { "s", function() require("substitute").visual() end, mode = "x", desc = "Substitute selection" },
  },
}
