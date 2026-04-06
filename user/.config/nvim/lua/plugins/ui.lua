return {
  -- ── Icons (dependency for many plugins) ────────────────────
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },

  -- ── Neo-tree: file explorer sidebar ────────────────────────
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    opts = {
      close_if_last_window = true,
      popup_border_style = "rounded",
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      },
      window = {
        width = 32,
        mappings = {
          ["<space>"] = "none", -- don't conflict with leader
        },
      },
      default_component_configs = {
        indent = {
          with_expanders = true,
        },
        git_status = {
          symbols = {
            added = "",
            modified = "",
            deleted = "✖",
            renamed = "󰁕",
            untracked = "",
            ignored = "",
            unstaged = "󰄱",
            staged = "",
            conflict = "",
          },
        },
      },
    },
    keys = {
      { "<leader>e", "<Cmd>Neotree toggle<CR>", desc = "Explorer" },
      { "-", "<Cmd>Neotree toggle<CR>", desc = "Explorer" },
      { "<leader>fe", "<Cmd>Neotree reveal<CR>", desc = "Reveal in explorer" },
    },
  },

  -- ── Telescope: fuzzy finder ────────────────────────────────
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
    },
    opts = function()
      local actions = require("telescope.actions")
      return {
        defaults = {
          prompt_prefix = "   ",
          selection_caret = " ",
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = {
              prompt_position = "top",
              preview_width = 0.5,
            },
            width = 0.87,
            height = 0.80,
          },
          sorting_strategy = "ascending",
          file_ignore_patterns = { "node_modules", ".git/" },
          mappings = {
            i = {
              ["<Esc>"] = actions.close,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
            },
          },
        },
        pickers = {
          find_files = {
            hidden = true,
          },
        },
      }
    end,
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      pcall(telescope.load_extension, "fzf")
    end,
    keys = {
      { "<leader><space>", "<Cmd>Telescope find_files<CR>", desc = "Find files" },
      { "<leader>ff", "<Cmd>Telescope find_files<CR>", desc = "Find files" },
      { "<leader>fg", "<Cmd>Telescope live_grep<CR>", desc = "Grep" },
      { "<leader>fb", "<Cmd>Telescope buffers<CR>", desc = "Buffers" },
      { "<leader>fh", "<Cmd>Telescope help_tags<CR>", desc = "Help" },
      { "<leader>fr", "<Cmd>Telescope oldfiles<CR>", desc = "Recent files" },
      { "<leader>/", "<Cmd>Telescope live_grep<CR>", desc = "Grep" },
      { "<leader>,", "<Cmd>Telescope buffers<CR>", desc = "Buffers" },
      { "<leader>:", "<Cmd>Telescope command_history<CR>", desc = "Command history" },
    },
  },

  -- ── Bufferline: tab bar ────────────────────────────────────
  {
    "akinsho/bufferline.nvim",
    version = "*",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        diagnostics = "nvim_lsp",
        always_show_bufferline = true,
        separator_style = "slant",
        show_buffer_close_icons = false,
        show_close_icon = false,
        offsets = {
          {
            filetype = "neo-tree",
            text = "Explorer",
            highlight = "Directory",
            separator = true,
          },
        },
      },
    },
    config = function(_, opts)
      local ok, cat_hl = pcall(function()
        return require("catppuccin.groups.integrations.bufferline").get()
      end)
      if ok and cat_hl then
        opts.highlights = cat_hl
      end
      require("bufferline").setup(opts)
    end,
    keys = {
      { "]b", "<Cmd>BufferLineCycleNext<CR>", desc = "Next buffer" },
      { "[b", "<Cmd>BufferLineCyclePrev<CR>", desc = "Previous buffer" },
      { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Pin buffer" },
      { "<leader>bo", "<Cmd>BufferLineCloseOthers<CR>", desc = "Close others" },
    },
  },

  -- ── Lualine: status bar ────────────────────────────────────
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "catppuccin",
        globalstatus = true,
        component_separators = { left = "│", right = "│" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "encoding", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      extensions = { "lazy", "neo-tree", "quickfix" },
    },
  },

  -- ── Which-key: shows available keybindings ─────────────────
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      delay = 200,
      spec = {
        { "<leader>b", group = "buffer" },
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>q", group = "quit" },
        { "<leader>u", group = "toggle" },
        { "<leader>w", group = "window" },
      },
    },
  },

  -- ── Noice: popup cmdline, messages, notifications ──────────
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      cmdline = {
        enabled = true,
        view = "cmdline_popup",
        format = {
          cmdline = { pattern = "^:", icon = " ", lang = "vim" },
          search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
          search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
          filter = { pattern = "^:%s*!", icon = " $", lang = "bash" },
          lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = " ", lang = "lua" },
          help = { pattern = "^:%s*he?l?p?%s+", icon = "󰋖 " },
        },
      },
      popupmenu = {
        enabled = false, -- let cmp handle cmdline completion
      },
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
        },
      },
      presets = {
        bottom_search = false,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = true,
      },
    },
    keys = {
      { "<leader>sn", "", desc = "+noice" },
      {
        "<S-Enter>",
        function() require("noice").redirect(vim.fn.getcmdline()) end,
        mode = "c",
        desc = "Redirect cmdline",
      },
      { "<leader>snl", function() require("noice").cmd("last") end, desc = "Noice last message" },
      { "<leader>snh", function() require("noice").cmd("history") end, desc = "Noice history" },
      { "<leader>snd", function() require("noice").cmd("dismiss") end, desc = "Dismiss all" },
    },
  },

  -- ── Notify: better notifications ──────────────────────────
  {
    "rcarriga/nvim-notify",
    lazy = true,
    opts = {
      timeout = 3000,
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
      render = "wrapped-compact",
    },
  },
}
