local ok, telescope = pcall(require, "telescope")
local nnoremap = require("her0elt.keymap").nnoremap

if not ok then
    return
end

telescope.setup()
require('telescope').load_extension('fzf')


nnoremap("<C-p>", function()
    require('telescope.builtin').git_files()
end)

nnoremap("<leader>pf", function()
    require('telescope.builtin').find_files()
end)

