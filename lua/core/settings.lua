local opts = {
	shiftwidth = 4,
	tabstop = 4,
    expandtab = true,
	wrap = false,
	termguicolors = true,
	number = true,
	relativenumber = true,
}

for opt, val in pairs(opts) do
	vim.o[opt] = val
end

vim.o["shiftwidth"] = 4
vim.o["tabstop"] = 4
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.api.nvim_set_option("clipboard", "unnamedplus")

local theme = require("utils.theme")
vim.cmd.colorscheme(theme)
