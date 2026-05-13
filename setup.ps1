#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Symlinks dotfiles into expected locations. Backs up existing files.
.USAGE
    git clone https://github.com/Vehnusian/dotfiles.git ~/dotfiles
    cd ~/dotfiles
    .\setup.ps1
#>

$ErrorActionPreference = "Stop"
$dotfiles = $PSScriptRoot

function Link {
    param([string]$Source, [string]$Target)

    if (-not (Test-Path $Source)) {
        Write-Host "  skip  $Source not found" -ForegroundColor Yellow
        return
    }

    $parent = Split-Path $Target -Parent
    if (-not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    if (Test-Path $Target) {
        $item = Get-Item $Target -Force
        if ($item.LinkType -eq "SymbolicLink") {
            Remove-Item $Target -Force
        } else {
            $backup = "$Target.bak.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
            Move-Item $Target $backup
            Write-Host "  backed up $Target" -ForegroundColor Yellow
        }
    }

    New-Item -ItemType SymbolicLink -Path $Target -Value $Source -Force | Out-Null
    Write-Host "  ok  $Target" -ForegroundColor Green
}

Write-Host "`ndotfiles: $dotfiles`n" -ForegroundColor Cyan

Link "$dotfiles\.gitconfig"                    "$HOME\.gitconfig"
Link "$dotfiles\.gitignore_global"             "$HOME\.gitignore_global"
Link "$dotfiles\.editorconfig"                 "$HOME\.editorconfig"
Link "$dotfiles\starship.toml"                 "$HOME\.config\starship.toml"
Link "$dotfiles\Microsoft.PowerShell_profile.ps1" "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"

$vsc = "$env:APPDATA\Code\User"
Link "$dotfiles\vscode-settings.json"          "$vsc\settings.json"
Link "$dotfiles\vscode-keybindings.json"       "$vsc\keybindings.json"

$wt = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
if (Test-Path $wt) {
    Link "$dotfiles\windows-terminal-settings.json" "$wt\settings.json"
}

Write-Host "`ndone — restart terminal to apply`n" -ForegroundColor Cyan
