return -- In your plugin list
{
	{"williamboman/mason.nvim", opts = {}},
	{"williamboman/mason-lspconfig.nvim", opts = {}},
	{"neovim/nvim-lspconfig"},
	{"hrsh7th/nvim-cmp", opts = {}},
	{"hrsh7th/cmp-nvim-lsp", opts = {}}, -- Crucial: allows cmp to see LSP data
	{"L3MON4D3/LuaSnip", opts = {}},     -- Required: cmp needs a snippet engine
}
