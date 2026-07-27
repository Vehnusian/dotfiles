<#
.SYNOPSIS
    Symlinks dotfiles into expected locations. Backs up existing files.
    Windows Terminal settings are copied (not symlinked) because Terminal
    auto-writes to that file on its own. Re-run setup.ps1 to refresh it.

    Needs symlink rights: either enable Windows Developer Mode
    (Settings > System > For developers) or run elevated.
.USAGE
    git clone https://github.com/Vehnusian/dotfiles.git ~/dotfiles
    cd ~/dotfiles
    .\setup.ps1
#>

$ErrorActionPreference = "Stop"
$dotfiles = $PSScriptRoot

# Verify we can create symlinks at all (Developer Mode or elevation).
$probe = Join-Path $env:TEMP "dotfiles-symlink-probe"
try {
    Remove-Item $probe -Force -ErrorAction SilentlyContinue
    New-Item -ItemType SymbolicLink -Path $probe -Target $PSCommandPath -ErrorAction Stop | Out-Null
    Remove-Item $probe -Force
} catch {
    Write-Host "Cannot create symlinks. Enable Developer Mode (Settings > System > For developers) or run elevated." -ForegroundColor Red
    exit 1
}

$wt = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
$vsc = "$env:APPDATA\Code\User"

$links = [ordered]@{
    "$HOME\.gitconfig"                = "$dotfiles\git\.gitconfig"
    "$HOME\.gitignore_global"         = "$dotfiles\git\.gitignore_global"
    "$HOME\.editorconfig"             = "$dotfiles\.editorconfig"
    "$HOME\.config\starship.toml"     = "$dotfiles\starship\starship.toml"
    $PROFILE.CurrentUserAllHosts      = "$dotfiles\powershell\profile.ps1"
    "$vsc\settings.json"              = "$dotfiles\vscode\settings.json"
    "$vsc\keybindings.json"           = "$dotfiles\vscode\keybindings.json"
    "$env:LOCALAPPDATA\nvim"          = "$dotfiles\nvim"
    "$env:APPDATA\yazi\config"        = "$dotfiles\yazi"
    "$env:APPDATA\lazygit\config.yml" = "$dotfiles\lazygit\config.yml"
}

Write-Host "`ndotfiles: $dotfiles`n" -ForegroundColor Cyan

# The AllHosts profile above is the single profile; a per-host symlink from an
# older setup would make every session load the profile twice.
$hostProfile = $PROFILE.CurrentUserCurrentHost
if (Test-Path $hostProfile) {
    $item = Get-Item $hostProfile -Force
    if ($item.LinkType -eq "SymbolicLink" -and $item.Target -like "*dotfiles*") {
        Remove-Item $hostProfile -Force
        Write-Host "  removed duplicate per-host profile symlink" -ForegroundColor Yellow
    }
}

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
            Remove-Item $target -Force -Recurse:$false
        } else {
            $backup = "$target.bak.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
            Move-Item $target $backup
            Write-Host "  backed up $target" -ForegroundColor Yellow
        }
    } elseif ((Get-Item $target -Force -ErrorAction SilentlyContinue)) {
        # Dangling symlink: Test-Path is false but the link exists.
        Remove-Item $target -Force
    }

    New-Item -ItemType SymbolicLink -Path $target -Target $source -Force | Out-Null
    Write-Host "  ok  $target  ->  symlink" -ForegroundColor Green
}

if (Test-Path $wt) {
    $wtTarget = "$wt\settings.json"
    $wtSource = "$dotfiles\windows-terminal\settings.json"

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

# SumatraPDF: LaTeX inverse search (double-click PDF -> jump to line in nvim).
$nvimExe = (Get-Command nvim -ErrorAction SilentlyContinue).Source
$sumatraSettings = "$env:LOCALAPPDATA\SumatraPDF\SumatraPDF-settings.txt"
if ($nvimExe -and (Test-Path (Split-Path $sumatraSettings -Parent))) {
    $inverse = "InverseSearchCmdLine = `"$nvimExe`" --headless -c `"VimtexInverseSearch %l '%f'`""
    $lines = @()
    if (Test-Path $sumatraSettings) {
        $lines = Get-Content $sumatraSettings | Where-Object {
            $_ -notmatch '^\s*InverseSearchCmdLine' -and $_ -notmatch '^\s*EnableTeXEnhancements'
        }
    }
    $lines + "EnableTeXEnhancements = true" + $inverse | Set-Content $sumatraSettings -Encoding UTF8
    Write-Host "  ok  SumatraPDF inverse search -> nvim" -ForegroundColor Green
}

Write-Host "`ndone — restart terminal to apply`n" -ForegroundColor Cyan
