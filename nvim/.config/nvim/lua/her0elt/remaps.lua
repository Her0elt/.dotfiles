local keymap = require("her0elt.keymap")

local nnoremap = keymap.nnoremap;
local vnoremap = keymap.vnoremap;

vim.g.mapleader = " "
nnoremap("<leader>pv", "<cmd>Ex<CR>")

vnoremap("J", ":m '>+1<CR>gv=gv")
vnoremap("K", ":m '<-2<CR>gv=gv")

nnoremap("Y", "yg$")
nnoremap("J", "mzJ`z")
vnoremap("<leader>y", "\"+y")
nnoremap("<leader>Y",  "\"+yg_")
nnoremap("<leader>y",  "\"+y")
nnoremap("<leader>yy",  "\"+yy")
