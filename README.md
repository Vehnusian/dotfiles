# dotfiles

Windows dev setup. PowerShell 7, Starship, Windows Terminal, VS Code. Catppuccin Mocha.

## Install

```powershell
git clone https://github.com/Vehnusian/dotfiles.git ~/dotfiles
cd ~/dotfiles
.\install.ps1
.\setup.ps1
```

`install.ps1` installs everything via winget. `setup.ps1` symlinks the configs (run as admin). Windows Terminal settings are *copied* rather than symlinked because Terminal writes to that file on its own; re-run `setup.ps1` to refresh from the repo.

## Update

```powershell
cd ~/dotfiles
.\update.ps1
```

Pulls latest and re-links.

## Stack

Shell `pwsh` · Prompt `starship` · Terminal `Windows Terminal` · Editor `VS Code`

CLI `gh` `git` `delta` `zoxide` `bat` `eza` `fzf` `ripgrep` `jq` `httpie` `lazygit` `fastfetch`

Python `uv` `ruff` · PS modules `PSFzf` `CompletionPredictor` `Terminal-Icons`
