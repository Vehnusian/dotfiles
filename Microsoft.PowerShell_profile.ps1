Invoke-Expression (&starship init powershell)

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

Set-Alias -Name g -Value git
Set-Alias -Name py -Value python
Set-Alias -Name c -Value code
Set-Alias -Name which -Value Get-Command
Set-Alias -Name touch -Value New-Item
if (Get-Command bat -ErrorAction SilentlyContinue) { Set-Alias -Name cat -Value bat }

function ll { Get-ChildItem -Force @args }
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function mkcd { param($dir) New-Item -ItemType Directory -Path $dir -Force | Out-Null; Set-Location $dir }

function gs { git status @args }
function ga { git add @args }
function gc { git commit @args }
function gp { git push @args }
function gl { git log --oneline -20 @args }
function gd { git diff @args }
function gco { git checkout @args }

$env:PYTHONDONTWRITEBYTECODE = 1
$env:BAT_THEME = "Catppuccin Mocha"
$env:FZF_DEFAULT_OPTS = "--height 40% --reverse --border"

Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -BellStyle None
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

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
