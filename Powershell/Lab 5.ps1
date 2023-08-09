param (
    [switch]$System,
    [switch]$Disks,
    [switch]$Network
)

function Get-SystemReport {
    $cpuInfo = Get-WmiObject Win32_Processor
    $osInfo = Get-WmiObject Win32_OperatingSystem
    $ramInfo = Get-WmiObject Win32_PhysicalMemory | Measure-Object Capacity -Sum
    $videoInfo = Get-WmiObject Win32_VideoController

    $report = @"
System Report
==============
CPU: $($cpuInfo.Name)
OS: $($osInfo.Caption)
RAM: $($ramInfo.Sum / 1GB) GB
Video: $($videoInfo.Name)
"@
    return $report
}

function Get-DisksReport {
    $disksInfo = Get-WmiObject Win32_LogicalDisk

    $report = @"
Disks Report
=============
$($disksInfo | ForEach-Object { "Drive $($_.DeviceID): $($_.Size / 1GB) GB Free Space" })
"@
    return $report
}

function Get-NetworkReport {
    $networkInfo = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true }

    $report = @"
Network Report
===============
$($networkInfo | ForEach-Object { "Adapter: $($_.Description)`nIP Address: $($_.IPAddress)" })
"@
    return $report
}

if ($PSCmdlet.MyInvocation.BoundParameters.Count -eq 0) {
    $fullReport = Get-SystemReport
    $fullReport += "`n`n" + Get-DisksReport
    $fullReport += "`n`n" + Get-NetworkReport
    Write-Host $fullReport
}
else {
    if ($System) {
        $systemReport = Get-SystemReport
        Write-Host $systemReport
    }
    if ($Disks) {
        $disksReport = Get-DisksReport
        Write-Host $disksReport
    }
    if ($Network) {
        $networkReport = Get-NetworkReport
        Write-Host $networkReport
    }
}
