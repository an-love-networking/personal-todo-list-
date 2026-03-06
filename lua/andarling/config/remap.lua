vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- move the block up down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- move to the consequent find and center the line on the screen
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- clipboard saver 
vim.keymap.set("v", "<leader>d", [["_dP]])

-- copy to clipboard
vim.keymap.set("n", "<leader>y", [["+y]])
vim.keymap.set("v", "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- select all
vim.keymap.set('n', '<leader>sa', [[gg0vG$]])

-- display function signature
vim.keymap.set('i', '<C-h>', vim.lsp.buf.signature_help, { desc = "Show Signature Help" })

-- terminal mode to normal
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>')
