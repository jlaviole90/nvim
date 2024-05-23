return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = function()
			pcall(require("nvim-treesitter.install").update({ with_sync = true }))
		end,
		depends = {
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"lua",
					"rust",
					"java",
					"go",
					"cpp",
					"angular",
					"c",
					"cpp",
					"c_sharp",
					"css",
					"html",
					"http",
					"javascript",
					"typescript",
					"json",
					"python",
					"scss",
					"sql",
					"xml",
					"yaml",
					"gitignore",
					"dockerfile",
					"properties",
				},
				sync_install = true,
				ignore_install = {},
				modules = {},
				auto_install = true,
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = true,
				},
				indent = {
					enable = true,
				},
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "gnn",
						node_incremental = "grn",
						scope_incremental = "grc",
						node_decremental = "grm",
					},
				},
				textobjects = {
					select = {
						enable = true,
						keymaps = {
							["af"] = "@function.outer",
							["if"] = "@function.inner",
							["ac"] = "@class.outer",
							["ic"] = "@class.inner",
						},
					},
				},
				rainbow = {
					enable = true,
					extended_mode = true,
					max_file_lines = 10000,
				},
			})

			vim.treesitter.language.register("html", "ejs")
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		opts = {
			enable = true,
			max_lines = 0,
			min_window_height = 0,
			line_numbers = true,
			multiline_threshold = 5,
			trim_scope = "outer",
			mode = "cursor",
			zindex = 20,
			on_attach = nil,
		},
	},
}
