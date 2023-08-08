# Get network adapter configuration objects for enabled adapters
$networkAdapters = Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled }

# Define a custom object to store adapter information
$adapterInfo = @()

# Iterate through each network adapter and gather required information
foreach ($adapter in $networkAdapters) {
    $info = [PSCustomObject]@{
        Description = $adapter.Description
        Index = $adapter.Index
        IPAddress = $adapter.IPAddress -join ', '
        SubnetMask = $adapter.IPSubnet -join ', '
        DNSDomain = $adapter.DNSDomain
        DNSServer = $adapter.DNSServerSearchOrder -join ', '
    }
    $adapterInfo += $info
}

# Display the report in a formatted table
$adapterInfo | Format-Table -AutoSize -Wrap Description, Index, IPAddress, SubnetMask, DNSDomain, DNSServer
