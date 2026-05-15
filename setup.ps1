#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Symlinks dotfiles into expected locations. Backs up existing files.
    Windows Terminal settings are copied (not symlinked) because Terminal
    auto-writes to that file on its own. Re-run setup.ps1 to refresh it.
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
    Write-Host "  ok  $target  ->  symlink" -ForegroundColor Green
}

if (Test-Path $wt) {
    $wtTarget = "$wt\settings.json"
    $wtSource = "$dotfiles\windows-terminal-settings.json"

    if (Test-Path $wtTarget) {
        $item = Get-Item $wtTarget -Force
        if ($item.LinkType -eq "SymbolicLink") {
            Remove-Item $wtTarget -Force
            Copy-Item $wtSource $wtTarget
            Write-Host "  ok  $wtTarget  ->  copy (replaced symlink)" -ForegroundColor Green
        } else {
            $backup = "$wtTarget.bak.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
            Copy-Item $wtTarget $backup
            Copy-Item $wtSource $wtTarget -Force
            Write-Host "  ok  $wtTarget  ->  copy (backed up existing)" -ForegroundColor Green
        }
    } else {
        Copy-Item $wtSource $wtTarget
        Write-Host "  ok  $wtTarget  ->  copy" -ForegroundColor Green
    }
}

Write-Host "`ndone — restart terminal to apply`n" -ForegroundColor Cyan
