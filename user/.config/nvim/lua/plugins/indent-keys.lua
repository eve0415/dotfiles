-- Disable Tab/S-Tab in blink.cmp so we can use them for indentation
return {
  {
    "saghen/blink.cmp",
    optional = true,
    opts = {
      keymap = {
        ["<Tab>"] = {},
        ["<S-Tab>"] = {},
      },
    },
  },
  {
    "hrsh7th/nvim-cmp",
    optional = true,
    opts = function(_, opts)
      local keys = opts.mapping or {}
      keys["<Tab>"] = nil
      keys["<S-Tab>"] = nil
      opts.mapping = keys
    end,
  },
  {
    "L3MON4D3/LuaSnip",
    optional = true,
    keys = function()
      -- Remove default Tab/S-Tab snippet jump mappings from LazyVim
      return {}
    end,
  },
}
