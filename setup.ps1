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

$wt = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
$vsc = "$env:APPDATA\Code\User"

$links = @{
    "$HOME\.gitconfig"                       = "$dotfiles\.gitconfig"
    "$HOME\.gitignore_global"                = "$dotfiles\.gitignore_global"
    "$HOME\.editorconfig"                    = "$dotfiles\.editorconfig"
    "$HOME\.config\starship.toml"            = "$dotfiles\starship.toml"
    $PROFILE.CurrentUserAllHosts             = "$dotfiles\Microsoft.PowerShell_profile.ps1"
    "$vsc\settings.json"                     = "$dotfiles\vscode-settings.json"
    "$vsc\keybindings.json"                  = "$dotfiles\vscode-keybindings.json"
}

if (Test-Path $wt) {
    $links["$wt\settings.json"] = "$dotfiles\windows-terminal-settings.json"
}

Write-Host "`ndotfiles: $dotfiles`n" -ForegroundColor Cyan

foreach ($pair in $links.GetEnumerator()) {
    $target = $pair.Key
    $source = $pair.Value

    if (-not (Test-Path $source)) {
        Write-Host "  skip  $source missing" -ForegroundColor Yellow
        continue
    }

    $parent = Split-Path $target -Parent
    if (-not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    if (Test-Path $target) {
        $item = Get-Item $target -Force
        if ($item.LinkType -eq "SymbolicLink") {
            Remove-Item $target -Force
        } else {
            $backup = "$target.bak.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
            Move-Item $target $backup
            Write-Host "  backed up $target" -ForegroundColor Yellow
        }
    }

    New-Item -ItemType SymbolicLink -Path $target -Value $source -Force | Out-Null
    Write-Host "  ok  $target" -ForegroundColor Green
}

Write-Host "`ndone — restart terminal to apply`n" -ForegroundColor Cyan
