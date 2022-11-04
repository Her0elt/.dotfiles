-- If you want icons for diagnostic errors, you'll need to define them somewhere:
vim.fn.sign_define("DiagnosticSignError", { text = " ", texthl = "DiagnosticSignError" })
vim.fn.sign_define("DiagnosticSignWarn", { text = " ", texthl = "DiagnosticSignWarn" })
vim.fn.sign_define("DiagnosticSignInfo", { text = " ", texthl = "DiagnosticSignInfo" })
vim.fn.sign_define("DiagnosticSignHint", { text = "", texthl = "DiagnosticSignHint" })

require("neo-tree").setup({
	close_if_last_window = true,
	visible = true, -- This is what you want: If you set this to `true`, all "hide" just mean "dimmed out"
	hide_dotfiles = false,
	filesystem = {
		filtered_items = {
			hide_dotfiles = false,
			hide_gitignored = false,
			hide_hidden = false,
		},
	},
})

vim.keymap.set("n", "<Leader>vv", "<Cmd>Neotree reveal toggle<CR>", { desc = "Toggle file tree" })
vim.keymap.set("n", "<Leader>pc", "<Cmd>Neotree action=close source=filesystem<CR>", { desc = "Close file tree" })
vim.keymap.set("n", "<Leader>pv", "<Cmd>Neotree reveal action=focus<CR>", { desc = "Focus file tree" })
