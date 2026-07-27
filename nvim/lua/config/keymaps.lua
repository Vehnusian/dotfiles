-- Keymaps are loaded on VeryLazy. LazyVim defaults:
-- https://www.lazyvim.org/configuration/keymaps

local map = vim.keymap.set

map("n", "<leader>fy", function()
  vim.fn.setreg("+", vim.fn.expand("%:p"))
  vim.notify("Copied path: " .. vim.fn.expand("%:p"))
end, { desc = "Yank file path" })
