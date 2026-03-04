local capabilities = require('cmp_nvim_lsp').default_capabilities()

require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = { "lua_ls", "pyright", "clangd", "rust_analyzer" }, -- Put your servers here
    handlers = {
        function(server_name) -- Default handler for all installed servers
            require("lspconfig")[server_name].setup({
                capabilities = capabilities
            })
        end,
    }
})

local cmp = require('cmp')

cmp.setup({
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }), 
	['<C-q>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
	['<C-e>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' }, -- This is the link to Mason/LSP
        { name = 'luasnip' },
    }, {
        { name = 'buffer' },
    })
})
