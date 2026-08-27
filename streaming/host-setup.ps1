<#
.SYNOPSIS
    Makes this machine a Sunshine streaming host, so another machine on the LAN
    can drive its desktop with Moonlight at near-native latency.

    Installs Sunshine, opens its ports on the Private profile only, and stops the
    machine sleeping or blanking while plugged in — screen capture dies with the
    display, so a laptop that sleeps takes the stream with it.

    Needs elevation: writes firewall rules and power settings.
.USAGE
    .\streaming\host-setup.ps1
    .\streaming\host-setup.ps1 -Subnet 10.0.0    # skip autodetection
#>

param([string]$Subnet)

$ErrorActionPreference = "Stop"

# Sunshine's installer usually adds these itself, but a single missing rule
# presents as "Moonlight cannot find the host", which is a miserable thing to
# debug. Cheaper to assert them.
$ports = [ordered]@{
    "TCP" = @{ Ports = @(47984, 47989, 47990, 48010); What = "https, http, web ui, rtsp" }
    "UDP" = @{ Ports = @(47998, 47999, 48000, 48002); What = "video, control, audio, mic" }
}

function Get-LanAddress {
    # The LAN adapter is the one that is up, holds a default gateway, and has an
    # RFC1918 address. That test skips APIPA, loopback, and the virtual adapters
    # Hyper-V, WSL and Bluetooth PAN leave behind.
    Get-NetIPConfiguration |
        Where-Object { $_.IPv4DefaultGateway -and $_.NetAdapter.Status -eq "Up" } |
        ForEach-Object { $_.IPv4Address } |
        Where-Object { $_.IPAddress -match '^(10\.|192\.168\.|172\.(1[6-9]|2[0-9]|3[01])\.)' } |
        Select-Object -First 1
}

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "Needs an elevated shell — firewall rules and power settings." -ForegroundColor Red
    exit 1
}

$lan = Get-LanAddress
if (-not $Subnet) {
    if (-not $lan) {
        Write-Host "No LAN adapter with a gateway found. Connect to the network, or pass -Subnet." -ForegroundColor Red
        exit 1
    }
    $Subnet = ($lan.IPAddress -split '\.')[0..2] -join '.'
}

Write-Host "`nhost: $($env:COMPUTERNAME)  subnet: $Subnet.0/24`n" -ForegroundColor Cyan

# --- Sunshine ---------------------------------------------------------------
$installed = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*,
                              HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* `
                              -ErrorAction SilentlyContinue |
             Where-Object { $_.DisplayName -like "*Sunshine*" } | Select-Object -First 1

if ($installed) {
    Write-Host "  ok  Sunshine $($installed.DisplayVersion) already installed" -ForegroundColor Green
} else {
    winget install --id LizardByte.Sunshine -e --silent --accept-source-agreements --accept-package-agreements 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ok  Sunshine installed" -ForegroundColor Green
    } else {
        Write-Host "  winget failed — https://github.com/LizardByte/Sunshine/releases" -ForegroundColor Yellow
    }
}

# --- Firewall ---------------------------------------------------------------
foreach ($proto in $ports.Keys) {
    $name = "Sunshine ($proto)"
    Get-NetFirewallRule -DisplayName $name -ErrorAction SilentlyContinue | Remove-NetFirewallRule
    New-NetFirewallRule -DisplayName $name -Direction Inbound -Action Allow `
        -Protocol $proto -LocalPort $ports[$proto].Ports -Profile Private | Out-Null
    Write-Host "  ok  $name  $($ports[$proto].Ports -join ', ')  — $($ports[$proto].What)" -ForegroundColor Green
}

Get-NetFirewallRule -DisplayName "Sunshine (mDNS)" -ErrorAction SilentlyContinue | Remove-NetFirewallRule
New-NetFirewallRule -DisplayName "Sunshine (mDNS)" -Direction Inbound -Action Allow `
    -Protocol UDP -LocalPort 5353 -Profile Private | Out-Null
Write-Host "  ok  Sunshine (mDNS)  5353  — autodiscovery" -ForegroundColor Green

# --- Network profile --------------------------------------------------------
# Only the adapter actually on this subnet, so running this on the road cannot
# quietly mark a cafe hotspot as trusted.
$onSubnet = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -like "$Subnet.*" }

if (-not $onSubnet) {
    Write-Host "  skip  nothing on $Subnet.* right now — re-run while on that network" -ForegroundColor Yellow
} else {
    foreach ($addr in $onSubnet) {
        $connProfile = Get-NetConnectionProfile -InterfaceIndex $addr.InterfaceIndex -ErrorAction SilentlyContinue
        if (-not $connProfile) { continue }
        if ($connProfile.NetworkCategory -ne "Private") {
            Set-NetConnectionProfile -InterfaceIndex $addr.InterfaceIndex -NetworkCategory Private
            Write-Host "  ok  $($addr.InterfaceAlias) -> Private" -ForegroundColor Green
        } else {
            Write-Host "  ok  $($addr.InterfaceAlias) already Private" -ForegroundColor Green
        }
    }
}

# --- Power ------------------------------------------------------------------
# AC only. On battery the machine should still be allowed to sleep.
powercfg /setacvalueindex SCHEME_CURRENT SUB_BUTTONS LIDACTION 0
powercfg /setacvalueindex SCHEME_CURRENT SUB_SLEEP STANDBYIDLE 0
powercfg /setacvalueindex SCHEME_CURRENT SUB_VIDEO VIDEOIDLE 0
powercfg /setactive SCHEME_CURRENT
Write-Host "  ok  plugged in: lid close does nothing, no sleep, display stays on" -ForegroundColor Green

# --- Where to point Moonlight ----------------------------------------------
if ($lan) {
    $speed = (Get-NetAdapter -InterfaceIndex $lan.InterfaceIndex -ErrorAction SilentlyContinue).LinkSpeed
    Write-Host "`n  point Moonlight at  $($lan.IPAddress)  ($($lan.InterfaceAlias), $speed)" -ForegroundColor Cyan
    if ($lan.InterfaceAlias -notmatch "Ethernet") {
        Write-Host "  on Wi-Fi — wire it in if you can, it is the usual cause of stutter" -ForegroundColor Yellow
    }
}

Write-Host "`nfinish at https://localhost:47990 — set a username, then pair the PIN`n" -ForegroundColor Cyan
Start-Process "https://localhost:47990"
