return {
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            require("nvim-tree").setup({
                disable_netrw = true,
                hijack_netrw = true,
                open_on_tab = false,
                hijack_cursor = false,
                update_focused_file = {
                    enable = true,
                    update_cwd = true,
                    ignore_list = {},
                },
                system_open = {
                    cmd = nil,
                    args = {},
                },
                view = {
                    width = 30,
                    side = "left",
                },
            })
            require("utils.keymaps").map("n", "<F12>", "<Cmd>NvimTreeToggle<CR>", "Toggle file tree")
        end,
    }
}
