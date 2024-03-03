---@type MappingsTable
local M = {}

M.general = {
  n = {
    [";"] = { ":", "enter command mode", opts = { nowait = true } },
    ["<C-h>"] = { "<cmd>TmuxNavigateLeft<CR>" },
    ["<C-j>"] = { "<cmd>TmuxNavigateDown<CR>" },
    ["<C-k>"] = { "<cmd>TmuxNavigateUp<CR>" },
    ["<C-l>"] = { "<cmd>TmuxNavigateRight<CR>" },

    --  format with conform
    ["<leader>fm"] = {
      function()
        require("conform").format()
      end,
      "formatting",
    },
  },
  v = {
    [">"] = { ">gv", "indent" },
  },
}

-- more keybinds!

return M
