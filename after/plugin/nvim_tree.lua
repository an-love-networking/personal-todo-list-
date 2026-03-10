-- require('nvim-tree').setup({
--     view = {
--         number = false,          -- Turn off absolute numbers in the tree
--         relativenumber = false,  -- Turn off relative numbers in the tree
--     }
-- })
-- 
-- -- show the sidebar
-- 
-- vim.cmd [[NvimTreeOpen]]
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    require("nvim-tree.api").tree.open()
  end
})
vim.keymap.set('n', '<C-s>', [[<Cmd>NvimTreeToggle<CR>]])
