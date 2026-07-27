-- LaTeX: VimTeX compiling with Tectonic, viewing in SumatraPDF with SyncTeX.
--   \ll  compile (single shot)   \lv  forward search to PDF
--   \le  show errors             \lc  clean aux files
--   \lo  compiler output         (localleader is \ in LazyVim)
--
-- Tectonic has no continuous mode, so saving a .tex/.bib file triggers a
-- single-shot rebuild instead; SumatraPDF reloads the PDF on its own.
--
-- Inverse search (double-click in the PDF -> jump to the source line) is passed
-- on SumatraPDF's command line rather than written into SumatraPDF-settings.txt,
-- because SumatraPDF rewrites that file when it exits and silently drops it.

-- SumatraPDF is not on PATH; resolve the install location instead.
local function sumatra_path()
  local candidates = {
    (vim.env.LOCALAPPDATA or "") .. "\\SumatraPDF\\SumatraPDF.exe",
    "C:\\Program Files\\SumatraPDF\\SumatraPDF.exe",
    "C:\\Program Files (x86)\\SumatraPDF\\SumatraPDF.exe",
  }
  for _, p in ipairs(candidates) do
    if vim.uv.fs_stat(p) then
      return p
    end
  end
  return "SumatraPDF" -- fall back to PATH
end

-- tectonic lives in ~/.local/bin, which only the pwsh profile puts on PATH.
-- Without this, nvim launched from Explorer/cmd/VS Code cannot compile.
local function ensure_local_bin()
  local local_bin = vim.fs.normalize(vim.fn.expand("~/.local/bin"))
  if vim.fn.isdirectory(local_bin) == 0 then
    return
  end
  local win = vim.fn.has("win32") == 1
  local sep = win and ";" or ":"
  local needle = win and local_bin:gsub("/", "\\") or local_bin
  local current = vim.env.PATH or ""
  if not current:lower():find(needle:lower(), 1, true) then
    vim.env.PATH = needle .. sep .. current
  end
end

return {
  {
    "lervag/vimtex",
    init = function()
      ensure_local_bin()

      vim.g.vimtex_compiler_method = "tectonic"
      vim.g.vimtex_compiler_tectonic = {
        options = { "--synctex", "--keep-logs" },
      }

      vim.g.vimtex_view_general_viewer = sumatra_path()
      vim.g.vimtex_view_general_options = string.format(
        [[-reuse-instance -forward-search @tex @line @pdf -inverse-search "%s --headless -c \"VimtexInverseSearch %%l '%%f'\""]],
        vim.v.progpath
      )

      vim.g.vimtex_quickfix_mode = 0 -- don't steal focus on warnings
    end,
    config = function()
      -- Tectonic can't watch files, so stand in for continuous mode: rebuild on
      -- write. VimtexCompileSS is the single-shot build; it no-ops with
      -- "Compiler is already running" if a previous build is still going.
      vim.api.nvim_create_autocmd("BufWritePost", {
        group = vim.api.nvim_create_augroup("vimtex_build_on_save", { clear = true }),
        pattern = { "*.tex", "*.bib" },
        callback = function()
          if vim.b.vimtex then
            vim.cmd("VimtexCompileSS")
          end
        end,
        desc = "Rebuild LaTeX on save (tectonic has no continuous mode)",
      })
    end,
  },
}
