local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true
opt.numberwidth = 4
opt.signcolumn = "yes"

-- Cursor
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.whichwrap:append("<,>,h,l")

-- Mouse & clipboard (like VSCode: mouse works, clipboard shared)
opt.mouse = "a"
opt.clipboard = "unnamedplus"

-- Appearance
opt.termguicolors = true
opt.wrap = false
opt.showmode = false
opt.laststatus = 3
opt.pumheight = 10
opt.fillchars = { eob = " " }

-- Splits (new splits open right/below like VSCode)
opt.splitright = true
opt.splitbelow = true
opt.splitkeep = "screen"

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true
opt.inccommand = "split"

-- Indentation (2 spaces, like typical VSCode default)
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true
opt.breakindent = true

-- Files
opt.undofile = true
opt.swapfile = false
opt.backup = false
opt.writebackup = false
opt.confirm = true
opt.updatetime = 250
opt.timeoutlen = 300

-- Completion
opt.completeopt = { "menuone", "noselect", "popup" }

-- Folding off by default
opt.foldenable = false

-- Use ripgrep for :grep
opt.grepprg = "rg --vimgrep --smart-case --hidden --glob !.git"
opt.grepformat = "%f:%l:%c:%m"
