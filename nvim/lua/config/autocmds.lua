-- Autocmds are loaded on VeryLazy. LazyVim defaults:
-- https://www.lazyvim.org/configuration/general#auto-commands

-- Prose-friendly settings for LaTeX and Markdown.
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "tex", "plaintex", "bib", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_ca"
  end,
})
