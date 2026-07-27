-- Options are loaded before lazy.nvim startup. LazyVim defaults:
-- https://www.lazyvim.org/configuration/general

-- Use pwsh for :!, :terminal, and plugin shell-outs.
vim.opt.shell = "pwsh"
vim.opt.shellcmdflag =
  "-NoLogo -NonInteractive -ExecutionPolicy RemoteSigned -Command [Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSStyle.OutputRendering='PlainText';"
vim.opt.shellredirect = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
vim.opt.shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
vim.opt.shellquote = ""
vim.opt.shellxquote = ""

vim.opt.relativenumber = true
vim.opt.wrap = false
vim.opt.scrolloff = 6

-- Prose-friendly defaults for LaTeX buffers live in autocmds.lua.
