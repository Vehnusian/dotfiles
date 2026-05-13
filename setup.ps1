#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Bootstrap script for dotfiles. Symlinks configs into their expected locations.
    Run on any new Windows machine after cloning the dotfiles repo.

.USAGE
    git clone https://github.com/Vehnusian/dotfiles.git ~/dotfiles
    cd ~/dotfiles
    # Run as Administrator (symlinks require it on Windows)
    .\setup.ps1
#>

$ErrorActionPreference = "Stop"
$dotfiles = $PSScriptRoot

function New-SafeSymlink {
    param(
        [string]$Source,
        [string]$Target
    )

    if (-not (Test-Path $Source)) {
        Write-Host "  SKIP: Source not found: $Source" -ForegroundColor Yellow
        return
    }

    $parent = Split-Path $Target -Parent
    if (-not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
        Write-Host "  Created directory: $parent" -ForegroundColor DarkGray
    }

    if (Test-Path $Target) {
        $existing = Get-Item $Target -Force
        if ($existing.LinkType -eq "SymbolicLink") {
            Remove-Item $Target -Force
        } else {
            $backup = "$Target.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
            Move-Item $Target $backup
            Write-Host "  Backed up existing file to: $backup" -ForegroundColor Yellow
        }
    }

    New-Item -ItemType SymbolicLink -Path $Target -Value $Source -Force | Out-Null
    Write-Host "  OK: $Target -> $Source" -ForegroundColor Green
}

Write-Host "`n=== Dotfiles Setup ===" -ForegroundColor Cyan
Write-Host "Source: $dotfiles`n"

# --- Git ---
Write-Host "[Git]" -ForegroundColor Magenta
New-SafeSymlink "$dotfiles\.gitconfig"       "$HOME\.gitconfig"
New-SafeSymlink "$dotfiles\.gitignore_global" "$HOME\.gitignore_global"

# --- Starship ---
Write-Host "[Starship]" -ForegroundColor Magenta
New-SafeSymlink "$dotfiles\starship.toml"    "$HOME\.config\starship.toml"

# --- PowerShell ---
Write-Host "[PowerShell]" -ForegroundColor Magenta
New-SafeSymlink "$dotfiles\Microsoft.PowerShell_profile.ps1" `
    "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"

# --- VS Code ---
Write-Host "[VS Code]" -ForegroundColor Magenta
$vscodePath = "$env:APPDATA\Code\User"
New-SafeSymlink "$dotfiles\vscode-settings.json"    "$vscodePath\settings.json"
New-SafeSymlink "$dotfiles\vscode-keybindings.json"  "$vscodePath\keybindings.json"

# --- Windows Terminal ---
Write-Host "[Windows Terminal]" -ForegroundColor Magenta
$wtPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
if (Test-Path $wtPath) {
    New-SafeSymlink "$dotfiles\windows-terminal-settings.json" "$wtPath\settings.json"
} else {
    Write-Host "  SKIP: Windows Terminal not found at expected path" -ForegroundColor Yellow
}

# --- EditorConfig ---
Write-Host "[EditorConfig]" -ForegroundColor Magenta
New-SafeSymlink "$dotfiles\.editorconfig" "$HOME\.editorconfig"

# --- Verify ---
Write-Host "`n=== Verification ===" -ForegroundColor Cyan
$checks = @(
    @{ Name = "Git config";      Path = "$HOME\.gitconfig" },
    @{ Name = "Global gitignore"; Path = "$HOME\.gitignore_global" },
    @{ Name = "Starship";        Path = "$HOME\.config\starship.toml" },
    @{ Name = "PowerShell profile"; Path = "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" },
    @{ Name = "VS Code settings"; Path = "$vscodePath\settings.json" },
    @{ Name = "EditorConfig";    Path = "$HOME\.editorconfig" }
)

foreach ($check in $checks) {
    if (Test-Path $check.Path) {
        $item = Get-Item $check.Path -Force
        if ($item.LinkType -eq "SymbolicLink") {
            Write-Host "  OK  $($check.Name)" -ForegroundColor Green
        } else {
            Write-Host "  !!  $($check.Name) (exists but NOT a symlink)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  XX  $($check.Name) (missing)" -ForegroundColor Red
    }
}

Write-Host "`n=== Done ===" -ForegroundColor Cyan
Write-Host "Restart your terminal to apply all changes.`n"
