return {
	{
		"nvim-lualine/lualine.nvim",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			local theme = require("utils.theme")
			local lualine_theme = theme == "default" and "auto" or theme
			require("lualine").setup({
				options = {
					icons_enabled = true,
					theme = lualine_theme,
					component_separators = { "", "" },
					section_separators = { "", "" },
				},
			})
		end,
	},
}
