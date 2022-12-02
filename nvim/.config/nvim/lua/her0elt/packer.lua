vim.cmd ([[packadd packer.nvim]])

return require("packer").startup(function(use)
	use("wbthomason/packer.nvim")
	use("theprimeagen/harpoon")
	use("nvim-lua/plenary.nvim")
	use("nvim-telescope/telescope.nvim")

	use("nvim-treesitter/nvim-treesitter", {
        	run = ":TSUpdate"
    	})

end)

	
