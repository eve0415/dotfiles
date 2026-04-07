return {
  -- ── blink.cmp: completion engine ───────────────────────────
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = {
      keymap = { preset = "default" },
      appearance = {
        nerd_font_variant = "mono",
      },
      completion = {
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 100,
        },
        ghost_text = { enabled = true },
        menu = {
          border = "rounded",
          draw = {
            columns = {
              { "kind_icon" },
              { "label", "label_description", gap = 1 },
              { "kind" },
            },
          },
        },
      },
      signature = { enabled = true },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      cmdline = {
        enabled = true,
        keymap = { preset = "inherit" },
        completion = {
          menu = { auto_show = true },
        },
        sources = function()
          local type = vim.fn.getcmdtype()
          if type == "/" or type == "?" then
            return { "buffer" }
          end
          if type == ":" then
            return { "cmdline" }
          end
          return {}
        end,
      },
      fuzzy = {
        implementation = "prefer_rust_with_warning",
      },
    },
    opts_extend = { "sources.default" },
  },

  -- ── Mason: LSP/tool installer ──────────────────────────────
  {
    "mason-org/mason.nvim",
    lazy = false,
    opts = {
      ui = { border = "rounded" },
    },
  },

  -- ── Mason-lspconfig: auto-install & enable LSP servers ─────
  {
    "mason-org/mason-lspconfig.nvim",
    lazy = false,
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      ensure_installed = {
        "ts_ls",
        "rust_analyzer",
      },
      automatic_enable = true,
    },
    config = function(_, opts)
      require("config.lsp").setup()
      require("mason-lspconfig").setup(opts)
    end,
  },

  -- ── nvim-lspconfig ─────────────────────────────────────────
  {
    "neovim/nvim-lspconfig",
    lazy = true,
  },

  -- ── Lazydev: Neovim Lua API completions ────────────────────
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },

  -- ── nvim-lint: extra linters (oxlint) ───────────────────────
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")

      -- Use oxlint when available in node_modules, alongside eslint LSP
      lint.linters_by_ft = {
        typescript = { "oxlint" },
        typescriptreact = { "oxlint" },
        javascript = { "oxlint" },
        javascriptreact = { "oxlint" },
      }

      -- Only run oxlint if it exists in the project
      lint.linters.oxlint = lint.linters.oxlint or {}
      local orig_oxlint = vim.deepcopy(lint.linters.oxlint)
      lint.linters.oxlint = vim.tbl_extend("force", orig_oxlint, {
        condition = function(ctx)
          return vim.fs.find("node_modules/.bin/oxlint", {
            upward = true,
            path = ctx.filename and vim.fn.fnamemodify(ctx.filename, ":h") or vim.fn.getcwd(),
          })[1] ~= nil
        end,
      })

      -- Lint on save, insert leave, and buffer enter
      vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave", "BufEnter" }, {
        group = vim.api.nvim_create_augroup("user_lint", { clear = true }),
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },

  -- ── conform.nvim: formatting ───────────────────────────────
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
      formatters_by_ft = {
        typescript = { "oxfmt", "biome", "prettier", stop_after_first = true },
        typescriptreact = { "oxfmt", "biome", "prettier", stop_after_first = true },
        javascript = { "oxfmt", "biome", "prettier", stop_after_first = true },
        javascriptreact = { "oxfmt", "biome", "prettier", stop_after_first = true },
        json = { "biome", "prettier", stop_after_first = true },
        css = { "prettier" },
        html = { "prettier" },
        markdown = { "prettier" },
        yaml = { "prettier" },
        rust = { "rustfmt" },
        lua = { "stylua" },
      },
      default_format_opts = {
        lsp_format = "fallback",
      },
      format_on_save = function(bufnr)
        if vim.g.autoformat == false then
          return
        end
        return {
          timeout_ms = 3000,
          lsp_format = "fallback",
        }
      end,
      formatters = {
        oxfmt = {
          -- Only use oxfmt when it exists in node_modules
          condition = function(self, ctx)
            return vim.fs.find("node_modules/.bin/oxfmt", {
              upward = true,
              path = ctx.dirname,
            })[1] ~= nil
          end,
        },
        biome = {
          condition = function(self, ctx)
            return vim.fs.find({ "biome.json", "biome.jsonc" }, {
              upward = true,
              path = ctx.dirname,
            })[1] ~= nil
          end,
        },
      },
    },
  },
}
