return {
  -- ── Treesitter: syntax highlighting ─────────────────────────
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    opts = {
      ensure_installed = {
        "bash",
        "c",
        "css",
        "diff",
        "go",
        "html",
        "javascript",
        "json",
        "lua",
        "luadoc",
        "markdown",
        "markdown_inline",
        "python",
        "regex",
        "rust",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
      },
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = { enable = true },
    },
    config = function(_, opts)
      require("nvim-treesitter").setup(opts)
    end,
  },

  -- ── Gitsigns: inline git markers ───────────────────────────
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      current_line_blame = true,
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local function m(lhs, rhs, desc)
          vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc, silent = true })
        end

        m("]h", gs.next_hunk, "Next hunk")
        m("[h", gs.prev_hunk, "Previous hunk")
        m("<leader>gp", gs.preview_hunk, "Preview hunk")
        m("<leader>gr", gs.reset_hunk, "Reset hunk")
        m("<leader>gs", gs.stage_hunk, "Stage hunk")
        m("<leader>gu", gs.undo_stage_hunk, "Undo stage hunk")
        m("<leader>gd", gs.diffthis, "Diff this")
        m("<leader>gb", gs.toggle_current_line_blame, "Toggle blame")
      end,
    },
  },

  -- Comment: gc/gcc is built into Neovim 0.10+, no plugin needed

  -- ── Autopairs: auto-close brackets ─────────────────────────
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },

  -- ── Indent guides ──────────────────────────────────────────
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      indent = { char = "│" },
      scope = { enabled = true, show_start = false, show_end = false },
    },
  },

  -- ── Autotag: linked editing for HTML/JSX tags (editor.linkedEditing) ──
  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    opts = {},
  },

  -- ── Colorizer: inline color previews ───────────────────────
  {
    "NvChad/nvim-colorizer.lua",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      filetypes = { "*" },
      user_default_options = {
        names = false,       -- don't highlight color names like "red"
        RGB = true,          -- #RGB
        RRGGBB = true,       -- #RRGGBB
        RRGGBBAA = true,     -- #RRGGBBAA
        rgb_fn = true,       -- rgb(), rgba()
        hsl_fn = true,       -- hsl(), hsla()
        css = true,          -- all CSS features (oklch, lch, lab, etc.)
        css_fn = true,       -- css color functions
        tailwind = true,     -- Tailwind CSS colors (bg-red-500, text-blue-300, etc.)
        mode = "virtualtext", -- "background", "foreground", or "virtualtext"
        virtualtext = "■",
        always_update = true,
      },
    },
  },
}
