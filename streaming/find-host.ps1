<#
.SYNOPSIS
    Finds Sunshine hosts on the LAN and checks the ports Moonlight needs.
    Run from the viewer machine when Moonlight cannot see the host.
.USAGE
    .\streaming\find-host.ps1
    .\streaming\find-host.ps1 -Address 192.168.2.50    # test one host
    .\streaming\find-host.ps1 -Subnet 10.0.0           # skip autodetection
#>

param(
    [string]$Address,
    [string]$Subnet
)

$ErrorActionPreference = "Stop"

# 47989 is Sunshine's plain-HTTP port and the one Moonlight hits first, so it
# doubles as the cheapest "is a host alive here" probe.
$probePort = 47989
# An array rather than a hashtable: indexing an ordered dictionary with an
# integer key is a positional lookup, not a key lookup, so port numbers as keys
# silently resolve to nothing.
$tcpPorts = @(
    [pscustomobject]@{ Port = 47984; Name = "https" }
    [pscustomobject]@{ Port = 47989; Name = "http" }
    [pscustomobject]@{ Port = 47990; Name = "web ui" }
    [pscustomobject]@{ Port = 48010; Name = "rtsp" }
)

function Get-LanAddress {
    Get-NetIPConfiguration |
        Where-Object { $_.IPv4DefaultGateway -and $_.NetAdapter.Status -eq "Up" } |
        ForEach-Object { $_.IPv4Address } |
        Where-Object { $_.IPAddress -match '^(10\.|192\.168\.|172\.(1[6-9]|2[0-9]|3[01])\.)' } |
        Select-Object -First 1
}

function Test-Port {
    param([string]$Target, [int]$Port, [int]$TimeoutMs = 500)

    $client = [System.Net.Sockets.TcpClient]::new()
    try {
        if ($client.ConnectAsync($Target, $Port).Wait($TimeoutMs)) { return $client.Connected }
        return $false
    } catch {
        return $false
    } finally {
        $client.Dispose()
    }
}

if (-not $Address) {
    if (-not $Subnet) {
        $lan = Get-LanAddress
        if (-not $lan) {
            Write-Host "No LAN adapter with a gateway found. Pass -Subnet or -Address." -ForegroundColor Red
            exit 1
        }
        $Subnet = ($lan.IPAddress -split '\.')[0..2] -join '.'
    }

    Write-Host "`nscanning $Subnet.0/24 for Sunshine..." -ForegroundColor Cyan

    # 254 sequential connects would take minutes, so fire them all at once and
    # wait on the batch. Refused connections fault their task rather than
    # throwing here, which is why nothing is wrapped in try/catch.
    $probes = 1..254 | ForEach-Object {
        $client = [System.Net.Sockets.TcpClient]::new()
        [pscustomobject]@{
            Address = "$Subnet.$_"
            Client  = $client
            Task    = $client.ConnectAsync("$Subnet.$_", $probePort)
        }
    }

    $timer = [Diagnostics.Stopwatch]::StartNew()
    while ($timer.ElapsedMilliseconds -lt 3000 -and ($probes.Task | Where-Object { -not $_.IsCompleted })) {
        Start-Sleep -Milliseconds 100
    }

    $found = @($probes | Where-Object { $_.Client.Connected } | ForEach-Object { $_.Address })
    $probes.Client | ForEach-Object { $_.Dispose() }

    if (-not $found) {
        Write-Host "  none found`n" -ForegroundColor Red
        Write-Host "  is the host powered on and on this network?"
        Write-Host "  did streaming\host-setup.ps1 finish without errors?"
        Write-Host "  on the host:  Get-Service *sunshine* | Select Name, Status" -ForegroundColor DarkGray
        Write-Host "  is the host's network profile Private rather than Public?`n"
        exit 1
    }

    $found | ForEach-Object { Write-Host "  found  $_" -ForegroundColor Green }
    $Address = $found[0]
    Write-Host ""
}

# --- Detail on one host -----------------------------------------------------
Write-Host "$Address" -ForegroundColor Cyan

$ping = Test-Connection -ComputerName $Address -Count 2 -ErrorAction SilentlyContinue
if ($ping) {
    $avg = [math]::Round(($ping | Measure-Object -Property Latency -Average).Average, 1)
    Write-Host "  ok  ping $avg ms" -ForegroundColor Green
    if ($avg -gt 10) {
        Write-Host "      high for a LAN — is the host on Wi-Fi?" -ForegroundColor Yellow
    }
} else {
    Write-Host "  --  no ping reply (some hosts block ICMP; not fatal)" -ForegroundColor Yellow
}

$closed = 0
foreach ($entry in $tcpPorts) {
    if (Test-Port -Target $Address -Port $entry.Port) {
        Write-Host "  ok  $($entry.Port) $($entry.Name)" -ForegroundColor Green
    } else {
        Write-Host "  --  $($entry.Port) $($entry.Name) closed" -ForegroundColor Red
        $closed++
    }
}

Write-Host ""
if ($closed -eq 0) {
    # The UDP media ports only bind once a session starts, so their absence here
    # is expected and not worth reporting.
    Write-Host "all ports open — add $Address in Moonlight`n" -ForegroundColor Green
} else {
    Write-Host "$closed port(s) closed — re-run streaming\host-setup.ps1 on the host`n" -ForegroundColor Yellow
    exit 1
}
