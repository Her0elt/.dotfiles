vim.cmd ([[packadd packer.nvim]])

return require("packer").startup(function(use)
    use("tpope/vim-fugitive")

	use("wbthomason/packer.nvim")
	use("theprimeagen/harpoon")
	use("nvim-lua/plenary.nvim")
	use("nvim-telescope/telescope.nvim")
    use({"nvim-telescope/telescope-fzf-native.nvim", run = "make" })
    use("nvim-treesitter/nvim-treesitter", {
        run = ":TSUpdate"
    })

    use("neovim/nvim-lspconfig")
    use("hrsh7th/cmp-nvim-lsp")
    use("hrsh7th/cmp-buffer")
    use("onsails/lspkind-nvim")
    use("nvim-lua/lsp_extensions.nvim")
    use({'tzachar/cmp-tabnine', run='./install.sh', requires = 'hrsh7th/nvim-cmp'})
    use("glepnir/lspsaga.nvim")
    use("simrat39/symbols-outline.nvim")
    use("L3MON4D3/LuaSnip")
    use("saadparwaiz1/cmp_luasnip")


    use("folke/tokyonight.nvim")
    use({"catppuccin/nvim", as = "catppuccin" })
    use({ 'rose-pine/neovim', as = 'rose-pine' })


end)


