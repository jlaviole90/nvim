return {
	{
		"lewis6991/gitsigns.nvim",
		opts = {},
	},
	{
		"akinsho/git-conflict.nvim",
		commit = "2957f74",
		config = function()
			require("git-conflict").setup({
				default_mappings = {
					ours = "co",
					theirs = "ct",
					none = "c0",
					both = "cb",
					next = "cn",
					prev = "cp",
				},
				debug = false,
				disable_diagnostics = true,
			})
		end,
	},
	{
		"tpope/vim-fugitive",
		config = function()
			local map = require("utils.keymaps").map
			map("n", "<leader>ga", "<cmd> Git add %<cr>", "Stage the current file")
		end,
	},
	{
		"FabijanZulj/blame.nvim",
		config = function()
			require("blame").setup()
			local map = require("utils.keymaps").map
			map("n", "<F7>", "<cmd>BlameToggle<cr>", "Toggle blame")
		end,
	},
}
