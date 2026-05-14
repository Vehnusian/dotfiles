# dotfiles

Windows 11 dev setup. PowerShell 7, Starship, Windows Terminal, VS Code, Catppuccin Mocha.

## Fresh machine

```powershell
git clone https://github.com/Vehnusian/dotfiles.git ~/dotfiles
cd ~/dotfiles
.\install.ps1                  # winget + PS modules + vscode extensions
.\setup.ps1                    # symlinks configs into place (run as admin)
```

Restart the terminal.

## Sync changes

```powershell
cd ~/dotfiles
.\update.ps1
```

## Layout

| File | Linked to |
| --- | --- |
| `Microsoft.PowerShell_profile.ps1` | `$PROFILE.CurrentUserAllHosts` |
| `starship.toml` | `~/.config/starship.toml` |
| `windows-terminal-settings.json` | Windows Terminal `settings.json` |
| `vscode-settings.json` / `vscode-keybindings.json` | `%APPDATA%\Code\User\` |
| `.gitconfig` / `.gitignore_global` / `.editorconfig` | `~` |

## Tools

`pwsh` `starship` `zoxide` `bat` `fzf` `ripgrep` `eza` `lazygit` `fastfetch` `gh` `uv`

PowerShell modules: `PSFzf` `CompletionPredictor` `Terminal-Icons` `PSScriptAnalyzer`

## Notes

`setup.ps1` is idempotent — re-run after pulling. Existing files are backed up with `.bak.{timestamp}` suffix.

The repo uses a whitelist `.gitignore` — only files explicitly un-ignored get tracked.
