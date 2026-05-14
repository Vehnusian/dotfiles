<#
.SYNOPSIS
    Installs the full dev environment via winget + PowerShell modules + VS Code extensions.
    Run once on a fresh Windows machine. Idempotent — safe to re-run.
.USAGE
    .\install.ps1
#>

$ErrorActionPreference = "Continue"

$wingetPackages = @(
    "Microsoft.PowerShell"
    "Microsoft.WindowsTerminal"
    "Microsoft.VisualStudioCode"
    "Git.Git"
    "GitHub.cli"
    "Starship.Starship"
    "ajeetdsouza.zoxide"
    "sharkdp.bat"
    "junegunn.fzf"
    "BurntSushi.ripgrep.MSVC"
    "eza-community.eza"
    "jesseduffield.lazygit"
    "fastfetch-cli.fastfetch"
    "astral-sh.uv"
    "Python.Python.3.13"
    "OpenJS.NodeJS.LTS"
    "DEVCOM.JetBrainsMonoNerdFont"
)

$psModules = @(
    "PSFzf"
    "CompletionPredictor"
    "PSScriptAnalyzer"
    "Terminal-Icons"
)

$vscodeExtensions = @(
    "Catppuccin.catppuccin-vsc"
    "Catppuccin.catppuccin-vsc-icons"
    "ms-python.python"
    "ms-python.autopep8"
    "EditorConfig.EditorConfig"
    "GitHub.vscode-pull-request-github"
    "eamodio.gitlens"
)

Write-Host "`nInstalling winget packages..." -ForegroundColor Cyan
foreach ($pkg in $wingetPackages) {
    Write-Host "  $pkg" -ForegroundColor DarkGray
    winget install --id $pkg -e --silent --accept-source-agreements --accept-package-agreements 2>&1 | Out-Null
}

Write-Host "`nInstalling PowerShell modules..." -ForegroundColor Cyan
foreach ($mod in $psModules) {
    Write-Host "  $mod" -ForegroundColor DarkGray
    Install-Module -Name $mod -Scope CurrentUser -Force -AcceptLicense -ErrorAction SilentlyContinue
}

Write-Host "`nInstalling VS Code extensions..." -ForegroundColor Cyan
foreach ($ext in $vscodeExtensions) {
    Write-Host "  $ext" -ForegroundColor DarkGray
    code --install-extension $ext --force 2>&1 | Out-Null
}

Write-Host "`ndone — run .\setup.ps1 next to symlink configs" -ForegroundColor Cyan
