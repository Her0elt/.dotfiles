vim.cmd ([[packadd packer.nvim]])

return require("packer").startup(function(use)
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
    use("hrsh7th/nvim-cmp")
    use("tzachar/cmp-tabnine", { run = "./install.sh" })
    use("onsails/lspkind-nvim")
    use("nvim-lua/lsp_extensions.nvim")
    use("glepnir/lspsaga.nvim")
    use("simrat39/symbols-outline.nvim")
    use("L3MON4D3/LuaSnip")
    use("saadparwaiz1/cmp_luasnip")


end)


