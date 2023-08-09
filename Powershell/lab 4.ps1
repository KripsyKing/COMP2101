# Function to get system hardware information
function Get-SystemHardware {
    return Get-WmiObject -Class Win32_ComputerSystem
}

# Function to get operating system information
function Get-OperatingSystem {
    return Get-WmiObject -Class Win32_OperatingSystem
}

# Function to get processor information
function Get-Processor {
    return Get-WmiObject -Class Win32_Processor
}

# Function to get physical memory information
function Get-PhysicalMemory {
    return Get-WmiObject -Class Win32_PhysicalMemory
}

# Function to get disk drive information
function Get-DiskDrives {
    $diskDrives = Get-WmiObject -Class Win32_DiskDrive

    $diskInfo = @()

    foreach ($disk in $diskDrives) {
        $partitions = $disk | Get-CimAssociatedInstance -ResultClassName CIM_diskpartition

        foreach ($partition in $partitions) {
            $logicalDisks = $partition | Get-CimAssociatedInstance -ResultClassName CIM_LogicalDisk

            foreach ($logicalDisk in $logicalDisks) {
                $diskInfo += [PSCustomObject]@{
                    Manufacturer = $disk.Manufacturer
                    Location = $partition.DeviceID
                    Drive = $logicalDisk.DeviceID
                    SizeGB = [math]::Round($logicalDisk.Size / 1GB, 2)
                    FreeSpaceGB = [math]::Round($logicalDisk.FreeSpace / 1GB, 2)
                    PercentageFree = [math]::Round(($logicalDisk.FreeSpace / $logicalDisk.Size) * 100, 2)
                }
            }
        }
    }

    return $diskInfo
}

# Function to get network adapter configuration
function Get-NetworkConfig {
    return Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled }
}

# Function to get video controller information
function Get-VideoController {
    return Get-WmiObject -Class Win32_VideoController
}

# Generate the report
$systemReport = @{
    SystemHardware = Get-SystemHardware
    OperatingSystem = Get-OperatingSystem
    Processor = Get-Processor
    PhysicalMemory = Get-PhysicalMemory
    DiskDrives = Get-DiskDrives
    NetworkConfig = Get-NetworkConfig
    VideoController = Get-VideoController
}

# Display the report
$systemReport.SystemHardware | Format-Table -AutoSize
$systemReport.OperatingSystem | Format-List
$systemReport.Processor | Format-List
$systemReport.PhysicalMemory | Format-Table -AutoSize
$systemReport.DiskDrives | Format-Table -AutoSize
$systemReport.NetworkConfig | Format-Table -AutoSize
$systemReport.VideoController | Format-List
