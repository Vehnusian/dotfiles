# --- Starship prompt ---
Invoke-Expression (&starship init powershell)

# --- Aliases ---
Set-Alias -Name g -Value git
Set-Alias -Name py -Value python
Set-Alias -Name c -Value code
Set-Alias -Name which -Value Get-Command
Set-Alias -Name touch -Value New-Item

function ll { Get-ChildItem -Force @args }
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function mkcd { param($dir) New-Item -ItemType Directory -Path $dir -Force | Out-Null; Set-Location $dir }

# --- Git shortcuts ---
function gs { git status @args }
function ga { git add @args }
function gc { git commit @args }
function gp { git push @args }
function gl { git log --oneline -20 @args }
function gd { git diff @args }
function gco { git checkout @args }

# --- Quality of life ---
$env:PYTHONDONTWRITEBYTECODE = 1

# PSReadLine tweaks
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -BellStyle None
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# Colors for PSReadLine (Catppuccin Mocha inspired)
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
