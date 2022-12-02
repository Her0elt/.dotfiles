local nnoremap = require("her0elt.keymap").nnoremap

nnoremap("<C-p>", function()
    require('telescope.builtin').git_files()
end)

nnoremap("<leader>pf", function()
    require('telescope.builtin').find_files()
end)

