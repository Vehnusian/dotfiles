<#
.SYNOPSIS
    Pulls latest dotfiles and re-runs setup.
.USAGE
    .\update.ps1
#>

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

Write-Host "`npulling..." -ForegroundColor Cyan
git pull --rebase

Write-Host "`nrelinking..." -ForegroundColor Cyan
& "$PSScriptRoot\setup.ps1"
