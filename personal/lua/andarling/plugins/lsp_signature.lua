return {
  "ray-x/lsp_signature.nvim",
  event = "VeryLazy",
  opts = {
    bind = true,
    handler_opts = { border = "rounded" },
    hint_enable = true, -- Show "virtual text" hint at the end of the line
    floating_window = true,
  },
  config = function(_, opts) require('lsp_signature').setup(opts) end,
}
