return {
    'romgrk/barbar.nvim',
    dependecies = {
        'nvim-tree/nvim-web-devicons', 
        'lewis6991/gitsigns.nvim', 
    },
    opts = {
        sidebar_filetypes = {
            -- Use the default values: {event = 'BufWinLeave', text = '', align = 'left'}
            NvimTree = true,
        },  
    }
}
