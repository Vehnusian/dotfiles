# dotfiles

My Windows development environment, reproducible from a fresh install in two commands. PowerShell 7, Positron, Starship, Windows Terminal, and a full command-line LaTeX workflow, themed end to end with Tokyo Night.

![Windows](https://img.shields.io/badge/Windows-11-89b4fa?style=flat-square&logo=windows11&logoColor=white)
![PowerShell](https://img.shields.io/badge/PowerShell-7-89b4fa?style=flat-square&logo=powershell&logoColor=white)
![Positron](https://img.shields.io/badge/IDE-Positron-a6e3a1?style=flat-square)
![theme: Tokyo Night](https://img.shields.io/badge/theme-Tokyo%20Night-7aa2f7?style=flat-square)
[![license: MIT](https://img.shields.io/badge/license-MIT-a6e3a1?style=flat-square)](LICENSE)

## Install

```powershell
git clone https://github.com/Vehnusian/dotfiles.git ~/dotfiles
cd ~/dotfiles
.\install.ps1      # install the toolchain via winget, PowerShell modules, tectonic, editor extensions
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
| `positron/` | [Positron](https://positron.posit.co) settings, keybindings, and debug configs: Tokyo Night, ruff, LaTeX Workshop. |
| `starship/starship.toml` | Starship prompt. Tokyo Night and Catppuccin palettes; switch with the `palette` key. |
| `windows-terminal/settings.json` | Windows Terminal profiles, theme, and font. |
| `lazygit/config.yml` | lazygit with delta paging. |
| `yazi/yazi.toml` | Yazi terminal file manager. |
| `latex/templates/` | Document templates used by `New-TexDoc`. |
| `git/.gitconfig`, `git/.gitignore_global` | Git config: delta pager, histogram diffs, zdiff3 conflicts, aliases. |
| `vscode/` | VS Code settings and keybindings, kept in sync with Positron so either editor behaves identically. |
| `install.ps1` / `setup.ps1` / `update.ps1` | Toolchain install · config symlinks · pull-and-relink. |

## LaTeX workflow

Fully local, fully command line. [Tectonic](https://tectonic-typesetting.github.io) compiles (downloads packages on demand, no TeX Live maintenance); SumatraPDF previews with SyncTeX in both directions.

```powershell
New-TexDoc paper     # scaffold paper/main.tex from the template
texb main.tex        # compile once (tectonic --synctex --keep-logs)
texw main.tex        # watch: rebuild on save, SumatraPDF live-reloads
```

In Positron and VS Code alike, LaTeX Workshop drives the same engine: saving a `.tex` file rebuilds it, `ctrl+alt+v` forward-searches to the PDF, and double-clicking in SumatraPDF jumps back to the source line.

## Data science

Positron's Console is a live session, so state persists between runs, DataFrames appear in the Variables pane, and plots render in the Plots pane. `install.ps1` installs `numpy`, `pandas`, `matplotlib`, `seaborn`, `plotly`, `scipy`, `ipywidgets` and `ipykernel`.

`Ctrl+Enter` runs the selection or current line. `F5` debugs, with inline variable values while paused. `positron/launch.json` holds debugpy configurations — it is **per-workspace**, so copy it into a project rather than expecting it to apply globally:

```powershell
mkdir .vscode; cp ~/dotfiles/positron/launch.json .vscode/launch.json
```

VS Code gets the equivalent via the Python and Jupyter extensions, which `install.ps1` installs; formatting is ruff in both, so switching editors changes nothing.

## Portability

Nothing in the tracked configs contains a username or absolute user path, so the repo moves between machines unchanged. Two mechanisms make that work:

- `~/.local/bin` is persisted to the User PATH, and `tectonic` lives there.
- SumatraPDF is symlinked into `~/.local/bin` as `sumatrapdf.exe`, so editor configs reference a bare `sumatrapdf` on PATH rather than an install location that varies by user and by installer.

On a new machine, `install.ps1` then `setup.ps1` is the whole bootstrap.

## How setup works

Configs are symlinked from the repo into the locations each tool expects, so editing a file in `~/dotfiles` updates the live config directly — and any change made on the machine is instantly visible to `git status`. The one exception is Windows Terminal, whose settings are **copied** rather than symlinked because Terminal rewrites that file on its own. Re-run `setup.ps1` to refresh it.

Symlinks require Windows Developer Mode (Settings → System → For developers) or an elevated shell; `setup.ps1` checks and tells you if neither is available.

## Stack

Shell `pwsh` · Prompt `starship` · Terminal `Windows Terminal` · Editor `Positron` / `VS Code` · Theme `Tokyo Night` · Font `JetBrains Mono Nerd Font`

CLI `gh` `git` `delta` `zoxide` `bat` `eza` `fd` `fzf` `ripgrep` `jq` `httpie` `lazygit` `yazi` `fastfetch`

LaTeX `tectonic` `SumatraPDF` `LaTeX Workshop` · Data science `numpy` `pandas` `matplotlib` `seaborn` `plotly` `ipykernel` · Runtimes `Python 3.13` (`uv`, `ruff`) · `Node LTS` · PowerShell modules `PSFzf` `CompletionPredictor` `Terminal-Icons` `PSScriptAnalyzer`

## License

[MIT](LICENSE).
