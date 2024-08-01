return {
	{
		"stevearc/conform.nvim",
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					lua = { "stylua" },
					go = { "gofumpt", "goimports", "golines", "gci" },
					javascript = { "prettier" },
					typescript = { "prettier" },
					html = { "prettier" },
					css = { "prettier", "stylelint" },
					python = { "black" },
					c = { "clang_format" },
					cpp = { "clang_format" },
					cs = { "csharpier" },
					cmake = { "gersemi" },
					java = { "google-java-format" },
					yaml = { "yamlfix" },
					rust = { "rustfmt" },
					xml = { "xmlformat" },
					sql = { "sqlfmt" },
				},
				formatters = {
					black = {
						command = "black",
					},
					clang_format = {
						command = "clang",
					},
					gci = {
						command = "gci",
					},
					gersemi = {
						command = "gersemi",
					},
					gofumpt = {
						command = "gofumpt",
					},
					goimports = {
						command = "goimports",
					},
					golines = {
						command = "golines",
					},
					google_java_format = {
						command = "java",
					},
					prettier = {
						command = "prettier",
					},
					rustfmt = {
						command = "rustfmt",
					},
					sqlfmt = {
						command = "sqlfmt",
					},
					stylelint = {
						command = "stylelint",
					},
					stylua = {
						command = "stylua",
					},
					xmlformat = {
						command = "xmlformat",
					},
					yamlfix = {
						command = "yamlfmt",
					},
				},
				notify_on_error = true,
			})

			local map = require("utils.keymaps").map

			vim.api.nvim_create_user_command("Format", function(args)
				local range = nil
				if args.count ~= -1 then
					local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
					range = {
						start = { args.line1, 0 },
						["end"] = { args.line2, end_line:len() },
					}
				end
				require("conform").format({ async = true, lsp_fallback = true, range = range })
			end, { range = true })

			map("n", "<F10>", "<Cmd>Format<CR>", "Format")
			map("n", "<F10><F10>", "<Cmd>OrganizeImports<CR>", "Organize imports (JS only)")
		end,
	},
}
