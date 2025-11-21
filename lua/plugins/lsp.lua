return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{
				"mason-org/mason.nvim",
				config = function()
					require("mason").setup()
				end,
			},
			{
				"mason-org/mason-lspconfig.nvim",
				after = { "mason.nvim", "nvim-lspconfig" },
				dependencies = { "neovim/nvim-lspconfig" },
				config = function()
					require("mason-lspconfig")
				end,
			},
			{
				"j-hui/fidget.nvim",
				tag = "legacy",
				event = "LspAttach",
			},
			"folke/neodev.nvim",
			"RRethy/vim-illuminate",
			"hrsh7th/cmp-nvim-lsp",
			"simrat39/rust-tools.nvim",
			"joeveiga/ng.nvim",
			"saecki/crates.nvim",
		},
		config = function()
			require("mason").setup({
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
			})

			require("neodev").setup()
			require("fidget").setup()
			require("crates").setup({})
			require("rust-tools").setup()

			local map = require("utils.keymaps").map
			map("n", "<leader>M", "<Cmd>Mason<CR>", "Show Mason")

			local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
			for type, icon in pairs(signs) do
				local hl = "DiagnosticSign" .. type
				vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
			end

			vim.diagnostic.config({
				virtual_text = false,
				signs = {
					active = signs,
				},
				update_in_insert = true,
				underline = true,
				severity_sort = true,
				float = {
					border = "rounded",
					source = true,
					header = "",
					prefix = "",
				},
			})

			vim.filetype.add({
				extension = {
					ejs = "html",
				},
			})

			local on_attach = function(client, bufnr)
				local lsp_map = require("utils.keymaps").lsp_map

				lsp_map("<leader>lr", vim.lsp.buf.rename, bufnr, "Rename symbol")
				lsp_map("<leader>la", vim.lsp.buf.code_action, bufnr, "Code action")
				lsp_map("<leader>ld", vim.lsp.buf.type_definition, bufnr, "Type definition")
				lsp_map("<leader>ls", require("telescope.builtin").lsp_document_symbols, bufnr, "Document symbols")

				lsp_map("gd", vim.lsp.buf.definition, bufnr, "Goto Definition")
				lsp_map("gr", require("telescope.builtin").lsp_references, bufnr, "Goto References")
				lsp_map("gI", vim.lsp.buf.implementation, bufnr, "Goto Implementation")
				lsp_map("K", vim.lsp.buf.hover, bufnr, "Hover Documentation")
				lsp_map("gD", vim.lsp.buf.declaration, bufnr, "Goto Declaration")

				vim.api.nvim_buf_create_user_command(bufnr, "LspFormat", function(_)
					vim.lsp.buf.format()
				end, { desc = "Format current buffer with LSP" })

				lsp_map("<leader>ff", "<cmd>LspFormat<cr>", bufnr, "LspFormat")

				require("illuminate").on_attach(client)
			end

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
			capabilities.textDocument.completion.completionItem.snippetSupport = true

			vim.lsp.enable("clangd")
			vim.lsp.config("clangd", { capabilities = capabilities, on_attach = on_attach })
			vim.lsp.enable("cmake")
			vim.lsp.config("cmake", { capabilities = capabilities, on_attach = on_attach })
			vim.lsp.enable("csharp_ls")
			vim.lsp.config("csharp_ls", { capabilities = capabilities, on_attach = on_attach })
			vim.lsp.enable("cssls")
			vim.lsp.config("cssls", { capabilities = capabilities, on_attach = on_attach })
			vim.lsp.enable("dockerls")
			vim.lsp.config("dockerls", { capabilities = capabilities, on_attach = on_attach })
			vim.lsp.enable("dotls")
			vim.lsp.config("dotls", { capabilities = capabilities, on_attach = on_attach })
			vim.lsp.enable("golangci_lint_ls")
			vim.lsp.config("golangci_lint_ls", { capabilities = capabilities, on_attach = on_attach })
			vim.lsp.enable("gopls")
			vim.lsp.config("gopls", { capabilities = capabilities, on_attach = on_attach })
			vim.lsp.enable("jsonls")
			vim.lsp.config("jsonls", { capabilities = capabilities, on_attach = on_attach })
			vim.lsp.enable("pyright")
			vim.lsp.config("pyright", { capabilities = capabilities, on_attach = on_attach })
			vim.lsp.enable("rust_analyzer")
			vim.lsp.config("rust_analyzer", { capabilities = capabilities, on_attach = on_attach })
			vim.lsp.enable("sqlls")
			vim.lsp.config("sqlls", { capabilities = capabilities, on_attach = on_attach })
			vim.lsp.enable("c3_lsp")
			vim.lsp.config("c3_lsp", { capabilities = capabilities, on_attach = on_attach, filetypes = { "c3" } })

			vim.lsp.enable("html")
			vim.lsp.config("html", {
				capabilities = capabilities,
				on_attach = on_attach,
				filetypes = { "html", "ejs" },
				init_options = {
					configurationSection = { "html", "css", "javascript" },
					embeddedLanguages = {
						css = true,
						javascript = true,
						typescript = true,
					},
				},
			})

			-- Lua
			vim.lsp.enable("lua_ls")
			vim.lsp.config("lua_ls", {
				on_attach = on_attach,
				capabilities = capabilities,
				settings = {
					Lua = {
						completion = {
							callSnippet = "Replace",
						},
						diagnostics = {
							globals = { "vim" },
						},
						workspace = {
							library = {
								[vim.fn.expand("$VIMRUNTIME/lua")] = true,
								[vim.fn.stdpath("config") .. "/lua"] = true,
							},
						},
					},
				},
			})

			-- Css Modules
			vim.lsp.enable("cssmodules_ls")
			vim.lsp.config("cssmodules_ls", {
				on_attach = function(client)
					client.server_capabilities.definitionProvider = false
					on_attach(client)
				end,
				capabilities = capabilities,
				init_options = {
					camelCase = "dashes",
				},
				filetypes = { "css", "scss", "less" },
			})

			-- TS Server
			vim.lsp.enable("ts_ls")
			vim.lsp.config("ts_ls", {
				on_attach = function(client, bufnr)
					on_attach(client, bufnr)
					vim.api.nvim_buf_create_user_command(bufnr, "OrganizeImports", function()
						local params = {
							command = "_typescript.organizeImports",
							arguments = { vim.api.nvim_buf_get_name(0) },
							title = "",
						}
						vim.lsp.buf.execute_command(params)
					end, { desc = "Organize imports (TypeScript)" })
				end,
				capabilities = capabilities,
			})

			-- Angular
			vim.lsp.enable("angularls")
			vim.lsp.config("angularls", {
				on_attach = on_attach,
				capabilities = capabilities,
				-- TODO: setup for template jumping
				-- cmd =
			})
		end,
		autoformat = true,
	},
	{
		"supermaven-inc/supermaven-nvim",
		config = function()
			require("supermaven-nvim").setup({
				keymaps = {
					accept_suggestion = "<S-Tab>",
					clear_suggestion = "<C-Tab>",
					accept_word = "<C-Space>",
				},
			})
		end,
	},
}
