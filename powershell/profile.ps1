$DOTFILES = "$HOME\dotfiles"
if ($env:Path -notlike "*$HOME\.local\bin*") { $env:Path = "$HOME\.local\bin;$env:Path" }
$env:EDITOR = "nvim"
$env:VISUAL = "nvim"

Invoke-Expression (&starship init powershell)

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

if (Get-Module -ListAvailable PSFzf) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
}

if (Get-Module -ListAvailable CompletionPredictor) {
    Import-Module CompletionPredictor
}

if (Get-Module -ListAvailable Terminal-Icons) {
    Import-Module Terminal-Icons
}

Set-Alias -Name g -Value git
Set-Alias -Name py -Value python
Set-Alias -Name c -Value code
Set-Alias -Name v -Value nvim
Set-Alias -Name vi -Value nvim
Set-Alias -Name vim -Value nvim
Set-Alias -Name lg -Value lazygit
Set-Alias -Name which -Value Get-Command
Set-Alias -Name touch -Value New-Item
if (Get-Command bat -ErrorAction SilentlyContinue) { Set-Alias -Name cat -Value bat }

function ll {
    if (Get-Command eza -ErrorAction SilentlyContinue) {
        eza --long --git --icons --group-directories-first @args
    } else {
        Get-ChildItem -Force @args
    }
}
function la {
    if (Get-Command eza -ErrorAction SilentlyContinue) {
        eza --long --all --git --icons --group-directories-first @args
    } else {
        Get-ChildItem -Force -Hidden @args
    }
}
function lt {
    if (Get-Command eza -ErrorAction SilentlyContinue) {
        eza --tree --level=2 --icons --group-directories-first @args
    }
}
function .. { Set-Location .. }
function ... { Set-Location ..\.. }

# yazi: cd to wherever you were when you quit
function y {
    $tmp = [System.IO.Path]::GetTempFileName()
    yazi @args --cwd-file="$tmp"
    $cwd = Get-Content -Path $tmp -Encoding UTF8
    if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
        Set-Location -LiteralPath ([System.IO.Path]::GetFullPath($cwd))
    }
    Remove-Item -Path $tmp
}
function mkcd { param($dir) New-Item -ItemType Directory -Path $dir -Force | Out-Null; Set-Location $dir }

function gs { git status @args }
function ga { git add @args }
function gc { git commit @args }
function gp { git push @args }
function gl { git log --oneline -20 @args }
function gd { git diff @args }
function gco { git checkout @args }

function Watch-Command {
    param(
        [Parameter(Mandatory)][string]$Command,
        [int]$Interval = 2
    )
    while ($true) {
        Clear-Host
        Write-Host "every ${Interval}s: $Command  ($(Get-Date -Format 'HH:mm:ss'))" -ForegroundColor DarkGray
        Write-Host ""
        Invoke-Expression $Command
        Start-Sleep -Seconds $Interval
    }
}
Set-Alias -Name watch -Value Watch-Command

function New-PyProject {
    param([Parameter(Mandatory)][string]$Name)

    New-Item -ItemType Directory -Path $Name -Force | Out-Null
    Set-Location $Name

    uv init --name $Name --python 3.13 | Out-Null
    git init -q

    @"
# Copy to .env and fill in values
# API_KEY=
"@ | Set-Content .env.example

    @"
.env
.venv/
__pycache__/
*.py[cod]
.ruff_cache/
dist/
build/
"@ | Set-Content .gitignore

    "# $Name`n" | Set-Content README.md
    Write-Host "created $Name" -ForegroundColor Green
}

# --- LaTeX (tectonic + SumatraPDF) ---
function texb { tectonic --synctex --keep-logs @args }

function texw {
    # Rebuild on save; SumatraPDF auto-reloads the PDF.
    param([Parameter(Mandatory)][string]$File)
    $File = (Resolve-Path $File).Path
    $dir = Split-Path $File -Parent
    tectonic --synctex --keep-logs $File
    $last = @{}
    foreach ($f in Get-ChildItem $dir -Recurse -Include *.tex, *.bib) {
        $last[$f.FullName] = $f.LastWriteTimeUtc.Ticks
    }
    Write-Host "watching $dir — ctrl-c to stop" -ForegroundColor DarkGray
    while ($true) {
        Start-Sleep -Milliseconds 500
        $changed = $false
        foreach ($f in Get-ChildItem $dir -Recurse -Include *.tex, *.bib) {
            if ($last[$f.FullName] -ne $f.LastWriteTimeUtc.Ticks) {
                $last[$f.FullName] = $f.LastWriteTimeUtc.Ticks
                $changed = $true
            }
        }
        if ($changed) {
            Write-Host "rebuilding $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor DarkGray
            tectonic --synctex --keep-logs $File
        }
    }
}

function New-TexDoc {
    param([Parameter(Mandatory)][string]$Name)
    New-Item -ItemType Directory -Path $Name -Force | Out-Null
    Copy-Item "$DOTFILES\latex\templates\article.tex" "$Name\main.tex"
    Set-Location $Name
    Write-Host "created $Name\main.tex — texb main.tex to build, texw main.tex to watch" -ForegroundColor Green
}

$env:PYTHONDONTWRITEBYTECODE = 1
$env:BAT_THEME = "Catppuccin Mocha"
$env:YAZI_FILE_ONE = "C:\Program Files\Git\usr\bin\file.exe"
$env:FZF_DEFAULT_OPTS = "--height 40% --reverse --border"

Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows
Set-PSReadLineOption -BellStyle None
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Ctrl+w -Function BackwardKillWord
Set-PSReadLineKeyHandler -Key Ctrl+d -Function DeleteCharOrExit

Set-PSReadLineOption -Colors @{
    Command   = '#89B4FA'
    Parameter = '#F5C2E7'
    String    = '#A6E3A1'
    Comment   = '#6C7086'
    Keyword   = '#CBA6F7'
    Variable  = '#FAB387'
    Operator  = '#94E2D5'
    Number    = '#FAB387'
    Type      = '#F9E2AF'
    Error     = '#F38BA8'
}
