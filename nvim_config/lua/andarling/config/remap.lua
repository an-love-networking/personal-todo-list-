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

-- terminal mode to normal
vim.keymap.set('t', '<leader><Esc>', '<C-\\><C-n>')

-- terminal mode
terminal_id = nil
vim.keymap.set('n', '<c-t>', function()
  local active_buf_id = vim.api.nvim_get_current_buf()
  if not terminal_id or not vim.api.nvim_buf_is_valid(terminal_id) then
    vim.cmd('terminal')
    terminal_id = vim.api.nvim_get_current_buf()
  else 
    if active_buf_id ~= terminal_id then
      vim.cmd('buffer ' .. terminal_id)
    else
      vim.cmd('b#')
    end
  end
end, { desc = "Toggle Terminal" })
