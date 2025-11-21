return {
	{
		"mfussenegger/nvim-dap",
		lazy = true,
	},
	{
		"mfussenegger/nvim-jdtls",
		ft = "java",
		dependencies = {
			"mfussenegger/nvim-dap",
		},
	},
}

