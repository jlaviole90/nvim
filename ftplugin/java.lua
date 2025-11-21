-- Ensure jdtls is loaded
local status, jdtls = pcall(require, "jdtls")
if not status then
	vim.notify("nvim-jdtls not found. Install with :Lazy sync", vim.log.levels.ERROR)
	return
end

-- Paths
local home = os.getenv("HOME")
local jdtls_path = home .. "/.local/share/nvim/mason/packages/jdtls"
local java_debug_path = home .. "/.local/share/nvim/mason/packages/java-debug-adapter"
local java_test_path = home .. "/.local/share/nvim/mason/packages/java-test"
local lombok_path = home .. "/.local/share/nvim/lombok.jar"
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = home .. "/.local/share/nvim/jdtls-workspaces/" .. project_name

-- Download Lombok if not present
if vim.fn.filereadable(lombok_path) == 0 then
	vim.fn.system({
		"curl",
		"-L",
		"-o",
		lombok_path,
		"https://projectlombok.org/downloads/lombok.jar",
	})
	if vim.v.shell_error ~= 0 then
		vim.notify("Failed to download Lombok", vim.log.levels.ERROR)
	end
end

-- Check if jdtls is installed
if vim.fn.isdirectory(jdtls_path) == 0 then
	vim.notify("jdtls not found. Install with :Mason and install 'jdtls'", vim.log.levels.ERROR)
	return
end

-- Determine OS config
local os_config = "config_mac"
if vim.fn.has("mac") == 1 then
	os_config = "config_mac"
elseif vim.fn.has("unix") == 1 then
	os_config = "config_linux"
else
	os_config = "config_win"
end

-- Find equinox launcher jar
local function find_jar(pattern, search_path)
	local found = vim.fn.glob(search_path .. "/" .. pattern, false, true)
	return found[1] or nil
end

local equinox_launcher = find_jar("org.eclipse.equinox.launcher_*.jar", jdtls_path .. "/plugins")
if not equinox_launcher then
	vim.notify("Could not find equinox launcher in " .. jdtls_path .. "/plugins", vim.log.levels.ERROR)
	return
end

-- Bundles for debugging and testing
local bundles = {}

-- Add java-debug adapter
if vim.fn.isdirectory(java_debug_path) == 1 then
	local debug_jar = find_jar("com.microsoft.java.debug.plugin-*.jar", java_debug_path .. "/extension/server")
	if debug_jar then
		table.insert(bundles, debug_jar)
	end
end

-- Add java-test (vscode-java-test extension)
if vim.fn.isdirectory(java_test_path) == 1 then
	local test_bundle_globs = {
		java_test_path .. "/extension/server/*.jar",
	}
	for _, glob in ipairs(test_bundle_globs) do
		local test_jars = vim.fn.glob(glob, false, true)
		if #test_jars > 0 then
			vim.list_extend(bundles, test_jars)
		end
	end
end

-- Java home
local java_home = "/Users/joshualaviolette/.sdkman/candidates/java/23-open"

-- Build jdtls command
local cmd = {
	java_home .. "/bin/java",
	"-Declipse.application=org.eclipse.jdt.ls.core.id1",
	"-Dosgi.bundles.defaultStartLevel=4",
	"-Declipse.product=org.eclipse.jdt.ls.core.product",
	"-Dlog.protocol=true",
	"-Dlog.level=ALL",
	"-Xms1g",
	"-Xmx2G",
	"--add-modules=ALL-SYSTEM",
	"--add-opens", "java.base/java.util=ALL-UNNAMED",
	"--add-opens", "java.base/java.lang=ALL-UNNAMED",
	"-jar", equinox_launcher,
	"-configuration", jdtls_path .. "/" .. os_config,
	"-data", workspace_dir,
}

-- Add Lombok if available
if vim.fn.filereadable(lombok_path) == 1 then
	table.insert(cmd, 10, "-javaagent:" .. lombok_path)
end

-- LSP capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

-- LSP on_attach
local function on_attach(client, bufnr)
	-- Keymaps
	local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
	local opts = { noremap = true, silent = true }
	
	-- Standard LSP keymaps
	buf_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
	buf_set_keymap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
	buf_set_keymap("n", "gr", "<cmd>lua require('telescope.builtin').lsp_references()<CR>", opts)
	buf_set_keymap("n", "gI", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
	buf_set_keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
	buf_set_keymap("n", "<leader>lr", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
	buf_set_keymap("n", "<leader>la", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
	buf_set_keymap("n", "<leader>ld", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
	buf_set_keymap("n", "<leader>ls", "<cmd>lua require('telescope.builtin').lsp_document_symbols()<CR>", opts)
	buf_set_keymap("n", "<leader>ff", "<cmd>lua vim.lsp.buf.format()<CR>", opts)
	
	-- Java-specific commands
	buf_set_keymap("n", "<leader>jo", "<cmd>lua require('jdtls').organize_imports()<CR>", opts)
	buf_set_keymap("n", "<leader>jv", "<cmd>lua require('jdtls').extract_variable()<CR>", opts)
	buf_set_keymap("v", "<leader>jv", "<cmd>lua require('jdtls').extract_variable(true)<CR>", opts)
	buf_set_keymap("n", "<leader>jc", "<cmd>lua require('jdtls').extract_constant()<CR>", opts)
	buf_set_keymap("v", "<leader>jc", "<cmd>lua require('jdtls').extract_constant(true)<CR>", opts)
	buf_set_keymap("v", "<leader>jm", "<cmd>lua require('jdtls').extract_method(true)<CR>", opts)
	
	-- Test keymaps
	buf_set_keymap("n", "<leader>tc", "<cmd>lua require('jdtls').test_class()<CR>", opts)
	buf_set_keymap("n", "<leader>tm", "<cmd>lua require('jdtls').test_nearest_method()<CR>", opts)
	
	-- DAP keymaps
	buf_set_keymap("n", "<F4>", "<cmd>lua require('dap').toggle_breakpoint()<CR>", opts)
	buf_set_keymap("n", "<F5>", "<cmd>lua require('dap').step_over()<CR>", opts)
	buf_set_keymap("n", "<F6>", "<cmd>lua require('dap').step_into()<CR>", opts)
	buf_set_keymap("n", "<F7>", "<cmd>lua require('dap').continue()<CR>", opts)
	buf_set_keymap("n", "<F8>", "<cmd>lua require('dap').step_out()<CR>", opts)
	buf_set_keymap("n", "<F9>", "<cmd>lua require('dap').terminate()<CR>", opts)
	
	-- Setup illuminate if available
	local status_illuminate, illuminate = pcall(require, "illuminate")
	if status_illuminate then
		illuminate.on_attach(client)
	end
	
	-- Setup DAP
	jdtls.setup_dap({ hotcodereplace = "auto" })
end

-- jdtls configuration
local config = {
	cmd = cmd,
	root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }),
	settings = {
		java = {
			eclipse = {
				downloadSources = true,
			},
			configuration = {
				updateBuildConfiguration = "interactive",
				runtimes = {
					{
						name = "JavaSE-23",
						path = "/Users/joshualaviolette/.sdkman/candidates/java/23-open",
						default = true,
					},
					{
						name = "JavaSE-17",
						path = "/Users/joshualaviolette/.sdkman/candidates/java/17.0.12-tem",
					},
				},
			},
			maven = {
				downloadSources = true,
			},
			implementationsCodeLens = {
				enabled = true,
			},
			referencesCodeLens = {
				enabled = true,
			},
			references = {
				includeDecompiledSources = true,
			},
			format = {
				enabled = true,
				settings = {
					url = vim.fn.stdpath("config") .. "/lang-servers/intellij-java-google-style.xml",
					profile = "GoogleStyle",
				},
			},
			signatureHelp = { enabled = true },
			contentProvider = { preferred = "fernflower" },
			completion = {
				favoriteStaticMembers = {
					"org.hamcrest.MatcherAssert.assertThat",
					"org.hamcrest.Matchers.*",
					"org.hamcrest.CoreMatchers.*",
					"org.junit.jupiter.api.Assertions.*",
					"java.util.Objects.requireNonNull",
					"java.util.Objects.requireNonNullElse",
					"org.mockito.Mockito.*",
				},
				importOrder = {
					"java",
					"javax",
					"com",
					"org",
				},
			},
			sources = {
				organizeImports = {
					starThreshold = 9999,
					staticStarThreshold = 9999,
				},
			},
			codeGeneration = {
				toString = {
					template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
				},
				useBlocks = true,
			},
		},
	},
	flags = {
		allow_incremental_sync = true,
	},
	init_options = {
		bundles = bundles,
	},
	on_attach = on_attach,
	capabilities = capabilities,
}

-- Start jdtls
jdtls.start_or_attach(config)
