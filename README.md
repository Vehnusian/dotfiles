# dotfiles

My Windows development environment, reproducible from a fresh install in two commands. PowerShell 7, Starship, Windows Terminal, and VS Code, themed end to end with Catppuccin Mocha.

![Windows](https://img.shields.io/badge/Windows-11-89b4fa?style=flat-square&logo=windows11&logoColor=white)
![PowerShell](https://img.shields.io/badge/PowerShell-7-89b4fa?style=flat-square&logo=powershell&logoColor=white)
![theme: Catppuccin Mocha](https://img.shields.io/badge/theme-Catppuccin%20Mocha-cba6f7?style=flat-square)
[![license: MIT](https://img.shields.io/badge/license-MIT-a6e3a1?style=flat-square)](LICENSE)

## Install

```powershell
git clone https://github.com/Vehnusian/dotfiles.git ~/dotfiles
cd ~/dotfiles
.\install.ps1      # install the toolchain via winget, PowerShell modules, VS Code extensions
.\setup.ps1        # symlink the configs into place (run as admin)
```

`install.ps1` is idempotent, so it is safe to re-run. `setup.ps1` backs up any existing file before it links, so it will not clobber a config you already have.

## Update

```powershell
cd ~/dotfiles
.\update.ps1       # pull latest and re-link
```

## What's inside

| File | What it does |
| --- | --- |
| `install.ps1` | Installs the toolchain via winget, plus PowerShell modules and VS Code extensions. Idempotent. |
| `setup.ps1` | Symlinks configs into their expected locations, backing up anything already there. |
| `update.ps1` | Pulls the latest and re-runs setup. |
| `Microsoft.PowerShell_profile.ps1` | PowerShell profile: Starship init, aliases, PSFzf, and helper functions. |
| `starship.toml` | Starship prompt with the Catppuccin Mocha palette and OS, git, language, and duration segments. |
| `.gitconfig` | Git config: delta pager, histogram diffs, zdiff3 conflicts, and a set of aliases. |
| `windows-terminal-settings.json` | Windows Terminal profiles, theme, and font. |
| `vscode-settings.json`, `vscode-keybindings.json` | VS Code settings and keybindings. |
| `.editorconfig`, `.gitignore_global` | Editor defaults and a global ignore list. |

## How setup works

Configs are symlinked from the repo into the locations each tool expects, so editing a file in `~/dotfiles` updates the live config directly. The one exception is Windows Terminal, whose settings are **copied** rather than symlinked because Terminal rewrites that file on its own. Re-run `setup.ps1` to refresh it from the repo.

## Stack

Shell `pwsh` · Prompt `starship` · Terminal `Windows Terminal` · Editor `VS Code` · Theme `Catppuccin Mocha` · Font `JetBrains Mono Nerd Font`

CLI `gh` `git` `delta` `zoxide` `bat` `eza` `fzf` `ripgrep` `jq` `httpie` `lazygit` `fastfetch`

Runtimes `Python 3.13` (`uv`, `ruff`) · `Node LTS` · PowerShell modules `PSFzf` `CompletionPredictor` `Terminal-Icons` `PSScriptAnalyzer`

## License

[MIT](LICENSE).
