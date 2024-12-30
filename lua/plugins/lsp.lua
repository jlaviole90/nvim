return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
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
			"mfussenegger/nvim-jdtls",
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

			require("mason-lspconfig").setup({
				automatic_installation = true,
			})

			require("neodev").setup()
			require("fidget").setup()
			-- TODO: this requires extensive setup.....
			require("jdtls")
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

			local lspconfig = require("lspconfig")
			lspconfig.clangd.setup({ capabilities = capabilities, on_attach = on_attach })
			lspconfig.cmake.setup({ capabilities = capabilities, on_attach = on_attach })
			lspconfig.csharp_ls.setup({ capabilities = capabilities, on_attach = on_attach })
			lspconfig.cssls.setup({ capabilities = capabilities, on_attach = on_attach })
			lspconfig.dockerls.setup({ capabilities = capabilities, on_attach = on_attach })
			lspconfig.dotls.setup({ capabilities = capabilities, on_attach = on_attach })
			lspconfig.golangci_lint_ls.setup({ capabilities = capabilities, on_attach = on_attach })
			lspconfig.gopls.setup({ capabilities = capabilities, on_attach = on_attach })
			lspconfig.jdtls.setup({ capabilities = capabilities, on_attach = on_attach })
			lspconfig.jsonls.setup({ capabilities = capabilities, on_attach = on_attach })
			lspconfig.pyright.setup({ capabilities = capabilities, on_attach = on_attach })
			lspconfig.rust_analyzer.setup({ capabilities = capabilities, on_attach = on_attach })
			lspconfig.sqlls.setup({ capabilities = capabilities, on_attach = on_attach })
            lspconfig.c3_lsp.setup({ capabilities = capabilities, on_attach = on_attach, filetypes = { "c3" }})

			lspconfig.html.setup({
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
			require("lspconfig")["lua_ls"].setup({
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
			require("lspconfig")["cssmodules_ls"].setup({
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
			require("lspconfig")["ts_ls"].setup({
				on_attach = on_attach,
				capabilities = capabilities,
				commands = {
					OrganizeImports = {
						function()
							local params = {
								command = "_typescript.organizeImports",
								arguments = { vim.api.nvim_buf_get_name(0) },
								title = "",
							}
							vim.lsp.buf.execute_command(params)
						end,
						description = "Organize Imports",
					},
				},
			})

			-- Angular
			require("lspconfig")["angularls"].setup({
				on_attach = on_attach,
				capabilities = capabilities,
				-- TODO: setup for template jumping
				-- cmd =
			})
		end,
		autoformat = true,
	},
}
