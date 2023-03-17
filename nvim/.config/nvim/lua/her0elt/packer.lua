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
    use({ 'mbbill/undotree' })
    use ({
        'numToStr/Comment.nvim',
        config = function()
            require('Comment').setup()
        end
    })


    use ({
      'VonHeikemen/lsp-zero.nvim',
      requires = {
        -- LSP Support
        {'neovim/nvim-lspconfig'},
        {'williamboman/mason.nvim'},
        {'williamboman/mason-lspconfig.nvim'},

        -- Autocompletion
        {'hrsh7th/nvim-cmp'},
        {'hrsh7th/cmp-buffer'},
        {'hrsh7th/cmp-path'},
        {'saadparwaiz1/cmp_luasnip'},
        {'hrsh7th/cmp-nvim-lsp'},
        {'hrsh7th/cmp-nvim-lua'},

        -- Snippets
        {'L3MON4D3/LuaSnip'},
        {'rafamadriz/friendly-snippets'},
        {'udalov/kotlin-vim'},
      }
    })

    use("folke/tokyonight.nvim")
    use("gruvbox-community/gruvbox")
    use({"catppuccin/nvim", as = "catppuccin" })
    use({ 'rose-pine/neovim', as = 'rose-pine' })


end)


