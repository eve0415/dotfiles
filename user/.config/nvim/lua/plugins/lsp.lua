-- Completion (cmdline for now, LSP sources added later)
return {
  {
    "hrsh7th/nvim-cmp",
    event = { "CmdlineEnter" },
    dependencies = {
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-cmdline",
    },
    config = function()
      local cmp = require("cmp")

      -- `:` command line — suggestions after first keystroke
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline", option = { ignore_cmds = {} } },
        }),
        matching = { disallow_symbol_nonprefix_matching = false },
      })

      -- `/` and `?` search — suggest words from current buffer
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })
    end,
  },
}
