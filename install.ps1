<#
.SYNOPSIS
  Universal 1-command Windows 10/11 network & local transfer speed optimizer.
.DESCRIPTION
  Auto-detects active connected network adapters (Wi-Fi / Ethernet) regardless of interface name,
  removes Windows multimedia network throttling, removes the 20% QoS bandwidth reservation cap,
  disables Delivery Optimization P2P bandwidth sharing, tunes TCP stack parameters, and enables
  SMB bandwidth throttling bypass for faster local network transfers.
#>
[CmdletBinding()]
param(
  [string[]]$DnsServers = @("1.1.1.1", "1.0.0.1", "8.8.8.8")
)

$ErrorActionPreference = "Continue"

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
  Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs -Wait
  exit 0
}

$mmPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
if (Test-Path $mmPath) {
  New-ItemProperty -Path $mmPath -Name "NetworkThrottlingIndex" -PropertyType DWord -Value 0xffffffff -Force | Out-Null
}

$qosPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched"
New-Item -Path $qosPath -Force | Out-Null
New-ItemProperty -Path $qosPath -Name "NonBestEffortLimit" -PropertyType DWord -Value 0 -Force | Out-Null

$doPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization"
New-Item -Path $doPath -Force | Out-Null
New-ItemProperty -Path $doPath -Name "DODownloadMode" -PropertyType DWord -Value 0 -Force | Out-Null

try {
  Set-SmbClientConfiguration -EnableBandwidthThrottling $false -EnableLargeMtu $true -Force -ErrorAction Stop
  Set-SmbServerConfiguration -EnableMultiChannel $true -Force -ErrorAction SilentlyContinue
} catch {}

netsh int tcp set global autotuninglevel=normal | Out-Null
netsh int tcp set global rss=enabled | Out-Null
netsh int tcp set global rsc=enabled | Out-Null
netsh int tcp set global ecncapability=disabled | Out-Null
netsh int tcp set heuristics disabled | Out-Null

$activeAdapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" -and $_.InterfaceDescription -notmatch "WireSock|WireGuard|Loopback|Virtual|Hyper-V|TAP|TUN" }

foreach ($ad in $activeAdapters) {
  Write-Output "Optimizing adapter: $($ad.Name) ($($ad.InterfaceDescription))"
  $hasDefaultRoute = Get-NetRoute -InterfaceAlias $ad.Name -DestinationPrefix "0.0.0.0/0" -ErrorAction SilentlyContinue
  if ($hasDefaultRoute) {
    Set-DnsClientServerAddress -InterfaceAlias $ad.Name -ServerAddresses $DnsServers -ErrorAction SilentlyContinue
  }
  Disable-NetAdapterPowerManagement -Name $ad.Name -ErrorAction SilentlyContinue
}

powercfg /setacvalueindex SCHEME_CURRENT 19cbb8fa-5279-450e-9fac-8a3d5fedd0c1 12bbebe6-58d6-4636-95bb-3217ef867c1a 0 | Out-Null
powercfg /setdcvalueindex SCHEME_CURRENT 19cbb8fa-5279-450e-9fac-8a3d5fedd0c1 12bbebe6-58d6-4636-95bb-3217ef867c1a 0 | Out-Null
powercfg /setactive SCHEME_CURRENT | Out-Null

ipconfig /flushdns | Out-Null
Write-Output "Windows network & local transfer optimization complete. Restart recommended for full effect."
