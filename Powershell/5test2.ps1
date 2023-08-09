param (
    [switch]$System,
    [switch]$Disks,
    [switch]$Network
)

function Get-SystemInfo {
    $cpuInfo = Get-WmiObject Win32_Processor | Select-Object Name, NumberOfCores
    $osInfo = Get-WmiObject Win32_OperatingSystem | Select-Object Caption, OSArchitecture
    $ramInfo = Get-WmiObject Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum | Select-Object @{Name="Capacity";Expression={$_.Sum / 1GB}}
    $videoInfo = Get-WmiObject Win32_VideoController | Select-Object Name, AdapterRAM

    [PSCustomObject]@{
        CPU = $cpuInfo.Name
        Cores = $cpuInfo.NumberOfCores
        OS = "$($osInfo.Caption) $($osInfo.OSArchitecture)"
        RAM = "$($ramInfo.Capacity) GB"
        Video = "$($videoInfo.Name) $($videoInfo.AdapterRAM / 1MB) MB"
    }
}

function Get-DisksInfo {
    $disksInfo = Get-WmiObject Win32_DiskDrive | Select-Object Model, Size

    $disksInfo | ForEach-Object {
        [PSCustomObject]@{
            Disk = $_.Model
            Size = "$($_.Size / 1GB) GB"
        }
    }
}

function Get-NetworkInfo {
    $networkInfo = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true } | Select-Object Description, IPAddress

    $networkInfo | ForEach-Object {
        [PSCustomObject]@{
            Adapter = $_.Description
            IPAddress = $_.IPAddress -join ', '
        }
    }
}

if ($System) {
    Get-SystemInfo
}

if ($Disks) {
    Get-DisksInfo
}

if ($Network) {
    Get-NetworkInfo
}

if (-not ($System -or $Disks -or $Network)) {
    $systemInfo = Get-SystemInfo
    $disksInfo = Get-DisksInfo
    $networkInfo = Get-NetworkInfo

    Write-Host "System Info:"
    $systemInfo | Format-Table -AutoSize

    Write-Host "Disks Info:"
    $disksInfo | Format-Table -AutoSize

    Write-Host "Network Info:"
    $networkInfo | Format-Table -AutoSize
}
