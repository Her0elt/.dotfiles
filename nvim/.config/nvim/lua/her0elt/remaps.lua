local keymap = require("her0elt.keymap")


local nnoremap = keymap.nnoremap;

vim.g.mapleader = " "
nnoremap("<leader>pv", "<cmd>Ex<CR>")
