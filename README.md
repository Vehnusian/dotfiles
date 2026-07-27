# dotfiles

My Windows development environment, reproducible from a fresh install in two commands. PowerShell 7, Neovim (LazyVim), Starship, Windows Terminal, and a full command-line LaTeX workflow, themed end to end with Catppuccin Mocha.

![Windows](https://img.shields.io/badge/Windows-11-89b4fa?style=flat-square&logo=windows11&logoColor=white)
![PowerShell](https://img.shields.io/badge/PowerShell-7-89b4fa?style=flat-square&logo=powershell&logoColor=white)
![Neovim](https://img.shields.io/badge/Neovim-LazyVim-a6e3a1?style=flat-square&logo=neovim&logoColor=white)
![theme: Catppuccin Mocha](https://img.shields.io/badge/theme-Catppuccin%20Mocha-cba6f7?style=flat-square)
[![license: MIT](https://img.shields.io/badge/license-MIT-a6e3a1?style=flat-square)](LICENSE)

## Install

```powershell
git clone https://github.com/Vehnusian/dotfiles.git ~/dotfiles
cd ~/dotfiles
.\install.ps1      # install the toolchain via winget, PowerShell modules, tectonic, VS Code extensions
.\setup.ps1        # symlink the configs into place (needs Developer Mode or an elevated shell)
```

`install.ps1` is idempotent, so it is safe to re-run. `setup.ps1` backs up any existing file before it links, so it will not clobber a config you already have.

## Update

```powershell
cd ~/dotfiles
.\update.ps1       # pull latest and re-link
```

## Layout

| Path | What it configures |
| --- | --- |
| `powershell/profile.ps1` | PowerShell profile: Starship, aliases, PSFzf, yazi `y` wrapper, LaTeX helpers. |
| `nvim/` | Neovim via [LazyVim](https://www.lazyvim.org): LSP, treesitter, telescope, Catppuccin, VimTeX. |
| `starship/starship.toml` | Starship prompt with the Catppuccin Mocha palette. |
| `windows-terminal/settings.json` | Windows Terminal profiles, theme, and font. |
| `lazygit/config.yml` | lazygit with Catppuccin theme and delta paging. |
| `yazi/yazi.toml` | Yazi terminal file manager. |
| `latex/templates/` | Document templates used by `New-TexDoc`. |
| `git/.gitconfig`, `git/.gitignore_global` | Git config: delta pager, histogram diffs, zdiff3 conflicts, aliases. |
| `vscode/` | VS Code settings and keybindings (kept as a fallback editor). |
| `install.ps1` / `setup.ps1` / `update.ps1` | Toolchain install · config symlinks · pull-and-relink. |

## LaTeX workflow

Fully local, fully command line. [Tectonic](https://tectonic-typesetting.github.io) compiles (downloads packages on demand, no TeX Live maintenance); SumatraPDF previews with SyncTeX in both directions.

```powershell
New-TexDoc paper     # scaffold paper/main.tex from the template
texb main.tex        # compile once (tectonic --synctex --keep-logs)
texw main.tex        # watch: rebuild on save, SumatraPDF live-reloads
```

Inside Neovim, VimTeX drives the same engine: `<localleader>ll` compiles, `<localleader>lv` forward-searches to the PDF, and double-clicking in SumatraPDF jumps back to the source line (inverse search is wired up by `setup.ps1`).

## How setup works

Configs are symlinked from the repo into the locations each tool expects, so editing a file in `~/dotfiles` updates the live config directly — and any change made on the machine is instantly visible to `git status`. The one exception is Windows Terminal, whose settings are **copied** rather than symlinked because Terminal rewrites that file on its own. Re-run `setup.ps1` to refresh it.

Symlinks require Windows Developer Mode (Settings → System → For developers) or an elevated shell; `setup.ps1` checks and tells you if neither is available.

## Stack

Shell `pwsh` · Prompt `starship` · Terminal `Windows Terminal` · Editor `Neovim (LazyVim)` · Theme `Catppuccin Mocha` · Font `JetBrains Mono Nerd Font`

CLI `gh` `git` `delta` `zoxide` `bat` `eza` `fd` `fzf` `ripgrep` `jq` `httpie` `lazygit` `yazi` `fastfetch`

LaTeX `tectonic` `SumatraPDF` `VimTeX` · Runtimes `Python 3.13` (`uv`, `ruff`) · `Node LTS` · `zig` (treesitter compiler) · PowerShell modules `PSFzf` `CompletionPredictor` `Terminal-Icons` `PSScriptAnalyzer`

## License

[MIT](LICENSE).
