return {
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/popup.nvim",
			"nvim-lua/plenary.nvim",
			-- Fuzzy Finder Algorithm which requires local dependencies to be built. Only load if `make` is available
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make", cond = vim.fn.executable("make") == 1 },
		},
		config = function()
			require("telescope").setup({
				defaults = {
					mappings = {
						i = {
							["<C-u>"] = false,
							["<C-d>"] = false,
						},
					},
				},
			})

			-- Enable telescope fzf native, if installed
			pcall(require("telescope").load_extension, "fzf")

			local map = require("utils.keymaps").map
			map("n", "<C-p>", require("telescope.builtin").keymaps, "Search keymaps")
			map("n", "<F9>", "<Cmd>Telescope live_grep<CR>", "Search in project")
			map("n", "<F8>", "<Cmd>Telescope treesitter<CR>", "Search in file")
		end,
	},
}
