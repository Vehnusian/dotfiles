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

# Positron resolves extensions from Open VSX, so only ids published there work.
# Its Python, Jupyter and debugpy support is built in and needs no extension.
$positronExtensions = @(
    "enkia.tokyo-night"
    "pkief.material-icon-theme"
    "charliermarsh.ruff"
    "james-yu.latex-workshop"
    "tamasfe.even-better-toml"
    "editorconfig.editorconfig"
)

# VS Code pulls from the Microsoft marketplace, so it additionally needs the
# Python/Jupyter extensions that Positron bundles.
$vscodeExtensions = @(
    "enkia.tokyo-night"
    "pkief.material-icon-theme"
    "charliermarsh.ruff"
    "James-Yu.latex-workshop"
    "tamasfe.even-better-toml"
    "EditorConfig.EditorConfig"
    "ms-python.python"
    "ms-python.debugpy"
    "ms-toolsai.jupyter"
    "GitHub.vscode-pull-request-github"
    "eamodio.gitlens"
)

# Data-science stack. Positron renders matplotlib/plotly in its Plots pane and
# DataFrames in the Variables pane; ipykernel backs the Console.
$pythonPackages = @(
    "ipykernel"
    "jupyter_client"
    "numpy"
    "pandas"
    "matplotlib"
    "seaborn"
    "plotly"
    "scipy"
    "ipywidgets"
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
# that only helps pwsh — without this, anything launched outside pwsh (an editor
# started from Explorer, cmd, a VS Code terminal) cannot find tectonic.
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if ($userPath -notlike "*$localBin*") {
    $newPath = if ([string]::IsNullOrEmpty($userPath)) { $localBin } else { "$userPath;$localBin" }
    [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
    Write-Host "  added $localBin to User PATH" -ForegroundColor DarkGray
}

# Symlink SumatraPDF into ~/.local/bin so editor configs can reference it as a
# bare `sumatrapdf` on PATH. Without this the LaTeX settings would need an
# absolute, username-specific path and would not survive moving machines.
$sumatra = @(
    "$env:LOCALAPPDATA\SumatraPDF\SumatraPDF.exe"
    "$env:ProgramFiles\SumatraPDF\SumatraPDF.exe"
    "${env:ProgramFiles(x86)}\SumatraPDF\SumatraPDF.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1

if ($sumatra) {
    $shim = "$localBin\sumatrapdf.exe"
    if (Test-Path $shim) { Remove-Item $shim -Force }
    New-Item -ItemType SymbolicLink -Path $shim -Target $sumatra -ErrorAction SilentlyContinue | Out-Null
    if (Test-Path $shim) {
        Write-Host "  sumatrapdf -> $sumatra" -ForegroundColor DarkGray
    } else {
        Write-Host "  could not symlink SumatraPDF (needs Developer Mode)" -ForegroundColor Yellow
    }
} else {
    Write-Host "  SumatraPDF not found — LaTeX preview will not work" -ForegroundColor Yellow
}

Write-Host "`nInstalling Python packages..." -ForegroundColor Cyan
python -m pip install --quiet --upgrade @pythonPackages 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host "  $($pythonPackages -join ', ')" -ForegroundColor DarkGray
} else {
    Write-Host "  pip install failed — check that python is on PATH" -ForegroundColor Yellow
}

Write-Host "`nInstalling Positron extensions..." -ForegroundColor Cyan
$positronCli = "$env:LOCALAPPDATA\Programs\Positron\bin\positron.cmd"
if (Test-Path $positronCli) {
    foreach ($ext in $positronExtensions) {
        Write-Host "  $ext" -ForegroundColor DarkGray
        & $positronCli --install-extension $ext --force 2>&1 | Out-Null
    }
} else {
    Write-Host "  Positron CLI not found — skipping" -ForegroundColor Yellow
}

Write-Host "`nInstalling VS Code extensions..." -ForegroundColor Cyan
if (Get-Command code -ErrorAction SilentlyContinue) {
    foreach ($ext in $vscodeExtensions) {
        Write-Host "  $ext" -ForegroundColor DarkGray
        code --install-extension $ext --force 2>&1 | Out-Null
    }
} else {
    Write-Host "  code CLI not found — skipping" -ForegroundColor Yellow
}

Write-Host "`ndone — run .\setup.ps1 next to symlink configs" -ForegroundColor Cyan
