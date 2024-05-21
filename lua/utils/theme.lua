local function get_if_available(name, opts)
	local lua_ok, colorscheme = pcall(require, name)
	if lua_ok then
		colorscheme.setup(opts)
		return name
	end

	local vim_ok, _ = pcall(vim.cmd.colorscheme, name)
	if vim_ok then
		return name
	end

	return "default"
end

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true

local theme = get_if_available("catppuccin")
-- local colorscheme = get_if_available('gruvbox')
-- local colorscheme = get_if_available('rose-pine')
-- local colorscheme = get_if_available('everforest')
-- local colorscheme = get_if_available('melange')
--
return theme
