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
    "Posit.Positron"
    "sharkdp.fd"
    "sxyazi.yazi"
    "SumatraPDF.SumatraPDF"
    "zig.zig"
    "astral-sh.uv"
    "astral-sh.ruff"
    "Python.Python.3.13"
    "OpenJS.NodeJS.LTS"
    "DEVCOM.JetBrainsMonoNerdFont"
    "jqlang.jq"
    "httpie.httpie"
    "dandavison.delta"
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
    "ms-vscode-remote.vscode-remote-extensionpack"
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

Write-Host "`nInstalling tectonic (LaTeX engine, not on winget)..." -ForegroundColor Cyan
$localBin = "$HOME\.local\bin"
New-Item -ItemType Directory -Force $localBin | Out-Null
if (-not (Test-Path "$localBin\tectonic.exe")) {
    $rel = Invoke-RestMethod https://api.github.com/repos/tectonic-typesetting/tectonic/releases/latest
    $asset = $rel.assets | Where-Object name -match 'x86_64-pc-windows-msvc\.zip$' | Select-Object -First 1
    $zip = "$env:TEMP\tectonic.zip"
    Invoke-WebRequest $asset.browser_download_url -OutFile $zip
    Expand-Archive $zip "$env:TEMP\tectonic-extract" -Force
    Get-ChildItem "$env:TEMP\tectonic-extract" -Recurse -Filter tectonic.exe |
        ForEach-Object { Copy-Item $_.FullName "$localBin\tectonic.exe" -Force }
    Remove-Item $zip, "$env:TEMP\tectonic-extract" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "  $($rel.tag_name) -> $localBin\tectonic.exe" -ForegroundColor DarkGray
} else {
    Write-Host "  already installed" -ForegroundColor DarkGray
}

# Persist ~/.local/bin to the User PATH. The pwsh profile prepends it too, but
# that only helps pwsh — without this, anything launched outside pwsh (nvim from
# Explorer, cmd, VS Code's terminal) cannot find tectonic.
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if ($userPath -notlike "*$localBin*") {
    $newPath = if ([string]::IsNullOrEmpty($userPath)) { $localBin } else { "$userPath;$localBin" }
    [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
    Write-Host "  added $localBin to User PATH" -ForegroundColor DarkGray
}

Write-Host "`nInstalling VS Code extensions..." -ForegroundColor Cyan
foreach ($ext in $vscodeExtensions) {
    Write-Host "  $ext" -ForegroundColor DarkGray
    code --install-extension $ext --force 2>&1 | Out-Null
}

Write-Host "`ndone — run .\setup.ps1 next to symlink configs" -ForegroundColor Cyan
