local group = vim.api.nvim_create_augroup("user_core", { clear = true })

-- Highlight text briefly after yanking (visual feedback)
vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Equalize splits when terminal is resized
vim.api.nvim_create_autocmd("VimResized", {
  group = group,
  callback = function()
    vim.cmd("wincmd =")
  end,
})

-- Reload files changed outside Neovim
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = group,
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

-- Restore cursor position when reopening a file
vim.api.nvim_create_autocmd("BufReadPost", {
  group = group,
  callback = function(ev)
    local line = vim.api.nvim_buf_get_mark(ev.buf, '"')[1]
    if line > 1 and line <= vim.api.nvim_buf_line_count(ev.buf) then
      vim.cmd('normal! g`"')
    end
  end,
})

-- Press q to close help, quickfix, man pages
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = { "help", "qf", "man", "notify", "checkhealth" },
  callback = function(ev)
    vim.keymap.set("n", "q", "<Cmd>close<CR>", { buffer = ev.buf, silent = true })
  end,
})
