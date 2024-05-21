--vim.cmd([[autocmd! ColorScheme * highlight NormalFloat guibg=#1f2335]])
--vim.cmd([[autocmd! ColorScheme * highlight FloatBorder guifg=white guibg=#1f2335]])
vim.cmd([[
    set signcolumn=yes
    autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false })
]])

vim.api.nvim_set_option("updatetime", 250)

-- Settings for the completion menu
vim.opt.completeopt = { "menuone", "noselect", "noinsert" }
-- Prevent "Press ENTER or type command to continue" message
vim.opt.shortmess = vim.opt.shortmess + { c = true }
