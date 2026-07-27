-- LaTeX: VimTeX compiling with Tectonic, viewing in SumatraPDF with SyncTeX.
--   <localleader>ll  compile          <localleader>lv  forward search to PDF
--   <localleader>le  show errors      <localleader>lc  clean aux files
-- Inverse search (double-click in SumatraPDF -> jump to source) is configured
-- by dotfiles/setup.ps1 in SumatraPDF-settings.txt.
return {
  {
    "lervag/vimtex",
    init = function()
      vim.g.vimtex_compiler_method = "tectonic"
      vim.g.vimtex_compiler_tectonic = {
        options = { "--synctex", "--keep-logs" },
      }
      vim.g.vimtex_view_general_viewer = "SumatraPDF"
      vim.g.vimtex_view_general_options = "-reuse-instance -forward-search @tex @line @pdf"
      vim.g.vimtex_quickfix_mode = 0 -- don't steal focus on warnings
    end,
  },
}
