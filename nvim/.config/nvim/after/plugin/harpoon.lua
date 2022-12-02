local nnoremap = require("her0elt.keymap").nnoremap

local harpoon_ui = require("harpoon.ui")
local harpoon_mark = require("harpoon.mark")

nnoremap("<leader>a", function() harpoon_mark.add_file() end)
nnoremap("<C-e>", function() harpoon_ui.toggle_quick_menu() end)
nnoremap("<C-a>", function() harpoon_ui.nav_file(1) end)
nnoremap("<C-s>", function() harpoon_ui.nav_file(2) end)
nnoremap("<C-n>", function() harpoon_ui.nav_file(3) end)
nnoremap("<C-m>", function() harpoon_ui.nav_file(4) end)
