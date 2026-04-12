local M = {}

vim.g.autoformat = true

local function make_capabilities()
  local ok, blink = pcall(require, "blink.cmp")
  if ok then
    return blink.get_lsp_capabilities()
  end
  return vim.lsp.protocol.make_client_capabilities()
end

function M.toggle_autoformat()
  vim.g.autoformat = not vim.g.autoformat
  vim.notify(
    "Autoformat " .. (vim.g.autoformat and "enabled" or "disabled"),
    vim.log.levels.INFO
  )
end

function M.format(bufnr)
  -- Prefer conform.nvim, fall back to LSP
  local ok, conform = pcall(require, "conform")
  if ok then
    conform.format({ bufnr = bufnr or 0, lsp_format = "fallback", timeout_ms = 3000 })
  else
    vim.lsp.buf.format({ bufnr = bufnr or 0, async = false, timeout_ms = 3000 })
  end
end

function M.setup()
  -- ── Suppress tsgo NO_RESULT_CALLBACK_FOUND noise ──────────
  -- tsgo sometimes responds to already-cancelled requests;
  -- harmless but noisy. Filter it out of the LSP log.
  local orig_rpc_err = vim.lsp.rpc.client_errors
  local notify = vim.notify
  vim.lsp.handlers["$/logTrace"] = function() end
  vim.notify = function(msg, level, opts)
    if type(msg) == "string" and msg:find("NO_RESULT_CALLBACK_FOUND") then
      return
    end
    return notify(msg, level, opts)
  end

  -- ── Diagnostics ───────────────────────────────────────────
  vim.diagnostic.config({
    severity_sort = true,
    underline = true,
    update_in_insert = false,
    virtual_text = {
      spacing = 2,
      source = "if_many",
    },
    signs = true,
    float = {
      border = "rounded",
      source = "if_many",
    },
  })

  -- ── Format command ────────────────────────────────────────
  vim.api.nvim_create_user_command("Format", function()
    M.format(0)
  end, { desc = "Format current buffer" })

  -- ── Global LSP capabilities ───────────────────────────────
  vim.lsp.config("*", {
    capabilities = make_capabilities(),
  })

  -- ── Per-server settings ───────────────────────────────────

  -- ── tsgo: native Go-based TypeScript LSP ───────────────────
  -- Install: npm install -g @typescript/native-preview
  -- tsgo speaks LSP directly (no wrapper), so settings use
  -- the same schema as VS Code's typescript.* namespace.
  vim.lsp.config("tsgo", {
    settings = {
      typescript = {
        preferences = {
          preferTypeOnlyAutoImports = true,
          autoImportFileExcludePatterns = { "vm", "node:vm" },
        },
        inlayHints = {
          includeInlayParameterNameHints = "all",
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
        },
        -- TODO: codelens disabled — tsgo crashes Neovim's renderer
        -- implementationsCodeLens = { enabled = true },
        -- referencesCodeLens = { enabled = true, showOnAllFunctions = true },
      },
      javascript = {
        preferences = {
          autoImportFileExcludePatterns = { "vm", "node:vm" },
        },
        inlayHints = {
          includeInlayParameterNameHints = "all",
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
        },
        -- TODO: codelens disabled — tsgo crashes Neovim's renderer
        -- implementationsCodeLens = { enabled = true },
        -- referencesCodeLens = { enabled = true, showOnAllFunctions = true },
      },
    },
  })
  vim.lsp.enable("tsgo")

  vim.lsp.config("rust_analyzer", {
    settings = {
      ["rust-analyzer"] = {
        checkOnSave = { command = "clippy" },
        cargo = { allFeatures = true },
        inlayHints = {
          bindingModeHints = { enable = true },
          closureReturnTypeHints = { enable = "always" },
          lifetimeElisionHints = { enable = "always" },
        },
      },
    },
  })

  vim.lsp.config("lua_ls", {
    settings = {
      Lua = {
        completion = { callSnippet = "Replace" },
        diagnostics = { globals = { "vim" } },
        hint = { enable = true },
        telemetry = { enable = false },
        workspace = { checkThirdParty = false },
      },
    },
  })

  -- ── Organize imports on save (editor.codeActionsOnSave) ────
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("user_lsp_organize_imports", { clear = true }),
    pattern = { "*.ts", "*.tsx", "*.js", "*.jsx" },
    callback = function(ev)
      local clients = vim.lsp.get_clients({ bufnr = ev.buf, name = "tsgo" })
      if #clients == 0 then return end
      local encoding = clients[1].offset_encoding or "utf-16"

      local function run_code_action(action_kind)
        local params = vim.lsp.util.make_range_params(0, encoding)
        params.context = {
          only = { action_kind },
          diagnostics = {},
        }
        local result = vim.lsp.buf_request_sync(ev.buf, "textDocument/codeAction", params, 3000)
        for _, res in pairs(result or {}) do
          for _, action in pairs(res.result or {}) do
            if action.edit then
              vim.lsp.util.apply_workspace_edit(action.edit, encoding)
            elseif action.command then
              vim.lsp.buf.execute_command(action.command)
            end
          end
        end
      end

      run_code_action("source.organizeImports")
      run_code_action("source.addMissingImports")
    end,
  })

  -- ── On-attach keymaps & features ──────────────────────────
  local group = vim.api.nvim_create_augroup("user_lsp", { clear = true })

  vim.api.nvim_create_autocmd("LspAttach", {
    group = group,
    callback = function(ev)
      local client = vim.lsp.get_client_by_id(ev.data.client_id)
      if not client then return end

      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc, silent = true })
      end

      -- Navigation (like VSCode: F12, Ctrl+click, etc.)
      map("n", "gd", vim.lsp.buf.definition, "Go to definition")
      map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
      map("n", "gr", vim.lsp.buf.references, "References")
      map("n", "gI", vim.lsp.buf.implementation, "Implementation")
      map("n", "gy", vim.lsp.buf.type_definition, "Type definition")
      map("n", "K", vim.lsp.buf.hover, "Hover docs")

      -- Diagnostics
      map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Next diagnostic")
      map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Previous diagnostic")
      map("n", "<leader>cd", vim.diagnostic.open_float, "Line diagnostics")

      -- Code actions (like VSCode: Ctrl+.)
      map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
      map("n", "<leader>cr", vim.lsp.buf.rename, "Rename symbol")
      map("n", "<leader>cf", function() M.format(ev.buf) end, "Format")

      -- Inlay hints toggle
      if client:supports_method("textDocument/inlayHint") then
        vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
        map("n", "<leader>uh", function()
          vim.lsp.inlay_hint.enable(
            not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }),
            { bufnr = ev.buf }
          )
        end, "Toggle inlay hints")
      end

      -- Codelens (ts.implementationsCodeLens)
      -- TODO: disabled — tsgo returns out-of-bounds positions that crash
      -- Neovim's codelens renderer. Re-enable when tsgo stabilizes.
      -- if client:supports_method("textDocument/codeLens") then
      --   vim.lsp.codelens.enable(true, { bufnr = ev.buf })
      -- end

      -- Document highlight (highlight other occurrences of word under cursor)
      if client:supports_method("textDocument/documentHighlight") then
        local hl_group = vim.api.nvim_create_augroup("user_lsp_highlight_" .. ev.buf, { clear = true })
        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
          group = hl_group,
          buffer = ev.buf,
          callback = vim.lsp.buf.document_highlight,
        })
        vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
          group = hl_group,
          buffer = ev.buf,
          callback = vim.lsp.buf.clear_references,
        })
      end
    end,
  })
end

return M
