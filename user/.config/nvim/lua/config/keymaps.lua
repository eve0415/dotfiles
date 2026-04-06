local map = vim.keymap.set

-- ── Save ──────────────────────────────────────────────────────
-- Ctrl+S saves everywhere, just like VSCode
map({ "n", "i", "v" }, "<C-s>", "<Cmd>update<CR>", { desc = "Save file", silent = true })

-- ── Move lines ────────────────────────────────────────────────
-- Alt+J/K moves lines up/down, just like VSCode
map("n", "<A-j>", "<Cmd>move .+1<CR>==", { desc = "Move line down", silent = true })
map("n", "<A-k>", "<Cmd>move .-2<CR>==", { desc = "Move line up", silent = true })
map("x", "<A-j>", ":move '>+1<CR>gv=gv", { desc = "Move selection down", silent = true })
map("x", "<A-k>", ":move '<-2<CR>gv=gv", { desc = "Move selection up", silent = true })

-- ── Search ────────────────────────────────────────────────────
map("n", "<Esc>", "<Cmd>nohlsearch<CR>", { desc = "Clear search highlight", silent = true })

-- ── Window / split management ─────────────────────────────────
map("n", "<C-h>", "<C-w>h", { desc = "Focus left split", silent = true })
map("n", "<C-j>", "<C-w>j", { desc = "Focus lower split", silent = true })
map("n", "<C-k>", "<C-w>k", { desc = "Focus upper split", silent = true })
map("n", "<C-l>", "<C-w>l", { desc = "Focus right split", silent = true })

map("n", "<leader>wv", "<Cmd>vsplit<CR>", { desc = "Vertical split", silent = true })
map("n", "<leader>ws", "<Cmd>split<CR>", { desc = "Horizontal split", silent = true })
map("n", "<leader>wd", "<Cmd>close<CR>", { desc = "Close split", silent = true })
map("n", "<leader>w=", "<C-w>=", { desc = "Equalize splits", silent = true })

-- ── Buffers ───────────────────────────────────────────────────
map("n", "<leader>bd", "<Cmd>bdelete<CR>", { desc = "Delete buffer", silent = true })

-- ── Quit ──────────────────────────────────────────────────────
map("n", "<leader>qq", "<Cmd>confirm qall<CR>", { desc = "Quit all", silent = true })

-- ── Plugin UIs ────────────────────────────────────────────────
map("n", "<leader>L", "<Cmd>Lazy<CR>", { desc = "Lazy", silent = true })

-- ── Better defaults ───────────────────────────────────────────
-- Keep cursor centered when scrolling
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down", silent = true })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up", silent = true })

-- Don't lose selection when indenting
map("v", "<", "<gv", { desc = "Indent left", silent = true })
map("v", ">", ">gv", { desc = "Indent right", silent = true })

-- Paste without overwriting register in visual mode
map("v", "p", '"_dP', { desc = "Paste (keep register)", silent = true })
