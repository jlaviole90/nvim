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

local theme = require("utils.theme")
vim.cmd.colorscheme(theme)
