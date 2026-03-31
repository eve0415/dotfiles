-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

vim.g.mapleader = " "

map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
map("n", "<leader>h", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- Better window navigation
-- Note: <C-h> is used for find-and-replace below (VS Code-style)
-- Use <C-w>h or LazyVim's default for window-left navigation
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Keep cursor centered
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Easier escape from insert mode
map("i", "jk", "<esc>", { desc = "Escape insert mode" })

-- VS Code-style keybindings
-- Save with Ctrl+S (all modes)
map({ "n", "i", "v", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

-- Undo / Redo
map("n", "<C-z>", "u", { desc = "Undo" })
map("i", "<C-z>", "<cmd>undo<cr>", { desc = "Undo" })
map("n", "<C-y>", "<C-r>", { desc = "Redo" })
map("i", "<C-y>", "<cmd>redo<cr>", { desc = "Redo" })

-- Find in file (Ctrl+F)
map("n", "<C-f>", "/", { desc = "Search in file" })

-- Find and replace (Ctrl+H) — uses grug-far if available, falls back to built-in
map("n", "<C-h>", function()
  local ok, grug = pcall(require, "grug-far")
  if ok then
    grug.open()
  else
    vim.api.nvim_feedkeys(":%s/", "n", false)
  end
end, { desc = "Find and replace" })

-- Select all (Ctrl+A)
map("n", "<C-a>", "ggVG", { desc = "Select all" })

-- Duplicate line down (Ctrl+Shift+D, like VS Code's Shift+Alt+Down)
map("n", "<C-S-d>", "<cmd>t.<cr>", { desc = "Duplicate line down" })
map("i", "<C-S-d>", "<cmd>t.<cr>", { desc = "Duplicate line down" })

-- Delete entire line (Ctrl+Shift+K)
map("n", "<C-S-k>", "<cmd>d<cr>", { desc = "Delete line" })
map("i", "<C-S-k>", "<cmd>d<cr>", { desc = "Delete line" })

-- Move line up/down (Alt+Up/Down)
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move line up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move line down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

-- Toggle comment (Ctrl+/)
map("n", "<C-/>", "gcc", { remap = true, desc = "Toggle comment" })
map("v", "<C-/>", "gc", { remap = true, desc = "Toggle comment" })

-- Indent / Unindent with Tab / Shift+Tab
map("n", "<Tab>", ">>", { desc = "Indent line" })
map("n", "<S-Tab>", "<<", { desc = "Unindent line" })
map("v", "<Tab>", ">gv", { desc = "Indent selection" })
map("v", "<S-Tab>", "<gv", { desc = "Unindent selection" })
map("i", "<S-Tab>", "<C-d>", { desc = "Unindent" })
