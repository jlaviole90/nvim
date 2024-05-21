return {
	"typicode/bg.nvim",

	"ellisonleao/gruvbox.nvim",

	{
		"catppuccin/nvim",
		name = "catppuccin",
        config = function()
            require("catppuccin").setup({
                integrations = {
                    cmp = true,
                    dashboard = true,
                    nvimtree = true,
                    mason = true,
                },
                transparent_background = true,
            })
        end,
	},

	{
		"rose-pine/nvim",
		name = "rose-pine",
	},

	"sainnhe/everforest",

	"savq/melange-nvim"
}
