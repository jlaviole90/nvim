local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end

--require('core.lazy')
require("core.settings")
require("utils.keymaps")
--require('plugins')

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({

	"nvim-treesitter/nvim-treesitter", --
	{ --
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
	}, --
	"lewis6991/impatient.nvim", --
	"pocco81/auto-save.nvim", --

	{
		"neoclide/coc.nvim",
		branch = "release",
	},
	{ --
		"catppuccin/nvim",
		as = "catppuccin",
		priority = 1000,
	}, --



	"saadparwaiz1/cmp_luasnip",--
	"L3MON4D3/LuaSnip",--
	"hrsh7th/nvim-cmp",--
	"hrsh7th/cmp-nvim-lsp",--
	"hrsh7th/cmp-nvim-lsp-signature-help",--
	"hrsh7th/cmp-vsnip",--
	"hrsh7th/cmp-path",--
	"hrsh7th/cmp-buffer",--

	{
		"neovim/nvim-lspconfig",
		autoformat = true,
	},

	"williamboman/mason.nvim",
	"williamboman/mason-lspconfig.nvim",

	"simrat39/rust-tools.nvim",
	"folke/neodev.nvim",
	"OmniSharp/Omnisharp-vim",
	"nickspoons/vim-sharpenup",
	"joeveiga/ng.nvim",
	{
		"mfussenegger/nvim-jdtls",
		dependencies = { "folke/which-key.nvim" },
	},
	{
		"saecki/crates.nvim",
		event = { "BufRead Cargo.toml" },
		config = function()
			require("crates").setup()
		end,
	},
	{
		"pmizio/typescript-tools.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
		opts = {},
	},

	"stevearc/conform.nvim",--

	{--
		"nvim-tree/nvim-tree.lua",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
	},--

	"nvim-lua/plenary.nvim",--
	"MunifTanjim/nui.nvim",--
	"3rd/image.nvim",--

	{--
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			options = { theme = "catppuccin" },
		},
	},--

	"github/copilot.vim",--

	{--
		"FabijanZulj/blame.nvim",
		config = function()
			require("blame").setup()
		end,
	},--

	{--
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/popup.nvim",
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-fzf-native.nvim",
		},
	},--
})

local opts = { silent = true, noremap = true, expr = true, replace_keycodes = false }
function _G.check_back_space()
	local col = vim.fn.col(".") - 1
	return col == 0 or vim.fn.getline("."):sub(col, col):match("%s") ~= nil
end
vim.keymap.set(
	"i",
	"<CR>",
	'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()',
	opts
)
vim.keymap.set("i", "<S-CR>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)
vim.keymap.set("i", "<cr>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts)

-- GIT BLAME
vim.keymap.set("n", "<F7>", "<Cmd>BlameToggle<CR>")
-- file tree toggle
vim.keymap.set("n", "<F12>", "<Cmd>NvimTreeToggle<CR>")
-- Search for a string in the project - live
vim.keymap.set("n", "<F9>", "<Cmd>Telescope live_grep<CR>")
-- Search for methods and fields in the file
vim.keymap.set("n", "<F8>", "<Cmd>Telescope treesitter<CR>")
-- Settings for the completion menu
vim.opt.completeopt = { "menuone", "noselect", "noinsert" }
-- Prevent "Press ENTER or type command to continue" message
vim.opt.shortmess = vim.opt.shortmess + { c = true }
vim.api.nvim_set_option("updatetime", 750)

require("catppuccin").setup({
	integrations = {
		cmp = true,
		dashboard = true,
		nvimtree = true,
		mason = true,
	},
	transparent_background = true,
})
vim.cmd.colorscheme("catppuccin")

vim.wo.number = true

-- TREESITTER
------------------------------------------
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
		"tsx",
		"xml",
		"yaml",
		"gitignore",
		"gitcommit",
		"dockerfile",
		"properties",
	},
	auto_install = true,
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = true,
	},
	ident = {
		enable = true,
	},
	rainbow = {
		enable = true,
		extended_mode = true,
		max_file_lines = nil,
	},
})

------------------------------------------
-- important: this comes before lspconfig!
local rt = require("rust-tools")
rt.setup({
	server = {
		on_attach = function(_, bufnr)
			vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
			vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
		end,
	},
})
require("neodev").setup({})

-- TODO: java requires extensive setup...
require("jdtls")
require("crates").setup({})

require("mason").setup({
	ui = {
		icons = {
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗",
		},
	},
})

------------------------------------------
--[===[
vim.cmd([[autocmd! ColorScheme * highlight NormalFloat guibg=#1f2335]])
vim.cmd([[autocmd! ColorScheme * highlight FloatBorder guifg=white guibg=#1f2335]])

local border = {
	{ "🭽", "FloatBorder" },
	{ "▔", "FloatBorder" },
	{ "🭾", "FloatBorder" },
	{ "▕", "FloatBorder" },
	{ "🭿", "FloatBorder" },
	{ "▁", "FloatBorder" },
	{ "🭼", "FloatBorder" },
	{ "▏", "FloatBorder" },
}

-- To instead override globally
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts3, ...)
	opts3 = opts3 or {}
	opts3.border = opts3.border or border
	return orig_util_open_floating_preview(contents, syntax, opts3, ...)
end

local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

local on_attach = function(_, bufnr)
	local function buf_set_option(...)
		vim.api.nvim_buf_set_option(bufnr, ...)
	end

	buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")

	local opts4 = { buffer = bufnr, noremap = true, silent = true }
	vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts4)
	vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts4)
	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts4)
	vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts4)
	vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts4)
	vim.keymap.set("n", "gr", vim.lsp.buf.references, opts4)
end

local ng = require("ng")

local optss = { noremap = true, silent = true }
vim.keymap.set("n", "<leader>at", ng.goto_template_for_component, optss)
vim.keymap.set("n", "<leader>ac", ng.goto_component_with_template_file, optss)
vim.keymap.set("n", "<leader>aT", ng.get_template_tcb, optss)

require("typescript-tools").setup({})

local ok, mason_registry = pcall(require, "mason-registry")
if not ok then
	vim.notify("mason-registry could not be loaded")
	return
end

local angularls_path = mason_registry.get_package("angular-language-server"):get_install_path()
local ng_cmd = {
	"ngserver",
	"--stdio",
	"--tsProbeLocations",
	table.concat({
		angularls_path,
		vim.uv.cwd(),
	}, ","),
	"--ngProbeLocations",
	table.concat({
		angularls_path .. "/node_modules/@angular/language-server",
		vim.uv.cwd(),
	}, ","),
}

lspconfig.angularls.setup({
	capabilities = capabilities,
	on_attach = on_attach,
	cmd = ng_cmd,
})
-- TODO

lspconfig.clangd.setup({ capabilities = capabilities, on_attach = on_attach })
lspconfig.cmake.setup({ capabilities = capabilities, on_attach = on_attach })
lspconfig.csharp_ls.setup({ capabilities = capabilities, on_attach = on_attach })
lspconfig.omnisharp.setup({
	cmd = { "dotnet", "~/documents/omnisharp-linux-arm64-net6.0/OmniSharp.dll" },
	capabilities = capabilities,
})
lspconfig.cssls.setup({ capabilities = capabilities, on_attach = on_attach })
lspconfig.cssmodules_ls.setup({
	capabilities = capabilities,
	on_attach = function(client)
		client.server_capabilities.definitionProvider = false
		on_attach(client)
	end,
	init_options = { camelCase = "dashes" },
	filetypes = { "css", "scss", "less" },
})
lspconfig.dockerls.setup({ capabilities = capabilities, on_attach = on_attach })
lspconfig.dotls.setup({ capabilities = capabilities, on_attach = on_attach })
lspconfig.golangci_lint_ls.setup({ capabilities = capabilities, on_attach = on_attach })
lspconfig.gopls.setup({ capabilities = capabilities, on_attach = on_attach })
lspconfig.html.setup({ capabilities = capabilities, on_attach = on_attach })
lspconfig.java_language_server.setup({ capabilities = capabilities, on_attach = on_attach })
lspconfig.jdtls.setup({ capabilities = capabilities, on_attach = on_attach })
lspconfig.jsonls.setup({ capabilities = capabilities, on_attach = on_attach })
lspconfig.lua_ls.setup({
	capabilities = capabilities,
	on_attach = on_attach,
	settings = { Lua = { diagnostics = { globals = { "vim" } } } },
})
lspconfig.pyright.setup({ capabilities = capabilities, on_attach = on_attach })
lspconfig.rust_analyzer.setup({ capabilities = capabilities, on_attach = on_attach })
lspconfig.sqlls.setup({ capabilities = capabilities, on_attach = on_attach })
lspconfig.tsserver.setup({
	capabilities = capabilities,
	on_attach = on_attach,
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
]===]
--
-----------------------------------------------------------------------------------------------
--[[
--- Code formatters! ---
require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		go = { "gofumpt", "goimports", "golines", "gci" },
		javascript = { { "prettier" } },
		typescript = { { "prettier", "tsserver" } },
		html = { { "prettier" } },
		css = { { "prettier" }, "stylelint" },
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
		-- python
		black = {
			command = "black",
		},
		clang_format = {
			command = "clang",
		},
		-- go package import order
		gci = {
			command = "gci",
		},
		gersemi = {
			command = "gersemi",
		},
		-- stricter gofmt
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

vim.keymap.set("n", "<F10>", "<Cmd>Format<CR><Cmd>OrganizeImports<CR>")
-----------------------------------------------------------------------------------------------

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true
require("nvim-tree").setup({
	view = {
		width = 40,
	},
})

local sign = function(opts2)
	vim.fn.sign_define(opts2.name, {
		texthl = opts2.name,
		text = opts2.text,
		numhl = "",
	})
end
sign({ name = "DiagnosticsSignError", text = "" })
sign({ name = "DiagnosticSignWarn", text = "" })
sign({ name = "DiagnosticSignHint", text = "" })
sign({ name = "DiagnosticsSignInfo", text = "" })
vim.diagnostic.config({
	virtual_text = false,
	signs = true,
	update_in_insert = true,
	underline = true,
	severity_sort = false,
	float = {
		border = "rounded",
		source = "always",
		header = "",
		prefix = "",
	},
})]]--
