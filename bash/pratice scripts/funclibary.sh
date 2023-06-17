#!/bin/bash

# Function to save error message with timestamp to the log file
errormessage() {
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local message="$1"

    echo "[ERROR][$timestamp] $message" >> /var/log/systeminfo.log

    if [[ "$verbose" == true ]]; then
        >&2 echo "Error: $message"
    fi
}

# Function to display the CPU report
cpureport() {
    echo "CPU Report"
    echo "----------"
    echo "Manufacturer and Model: $(cat /proc/cpuinfo | grep "model name" | head -n 1 | cut -d ':' -f 2 | sed -e 's/^[[:space:]]*//')"
    echo "Architecture: $(uname -m)"
    echo "Core Count: $(nproc)"
    echo "Maximum CPU Speed: $(lscpu | grep "CPU max MHz" | cut -d ':' -f 2 | sed -e 's/^[[:space:]]*//' | awk '{printf "%.2f GHz\n", $1/1000}')"
    echo "Cache Sizes:"
    echo "  L1 Cache: $(lscpu | grep "L1d cache" | cut -d ':' -f 2 | sed -e 's/^[[:space:]]*//' | awk '{printf "%.2f kB\n", $1/1024}')"
    echo "  L2 Cache: $(lscpu | grep "L2 cache" | cut -d ':' -f 2 | sed -e 's/^[[:space:]]*//' | awk '{printf "%.2f MB\n", $1/1024}')"
    echo "  L3 Cache: $(lscpu | grep "L3 cache" | cut -d ':' -f 2 | sed -e 's/^[[:space:]]*//' | awk '{printf "%.2f MB\n", $1/1024}')"
}

# Function to display the computer report
computerreport() {
    echo "Computer Report"
    echo "---------------"
    echo "Manufacturer: $(sudo dmidecode -s system-manufacturer)"
    echo "Description or Model: $(sudo dmidecode -s system-product-name)"
    echo "Serial Number: $(sudo dmidecode -s system-serial-number)"
}

# Function to display the OS report
osreport() {
    echo "OS Report"
    echo "---------"
    echo "Linux Distro: $(lsb_release -sd)"
    echo "Distro Version: $(lsb_release -sr)"
}

# Function to display the RAM report
ramreport() {
    echo "RAM Report"
    echo "----------"
    echo "Component Manufacturer    Model                  Size    Speed    Location"
    echo "-------------------------------------------------------------------------"
    local total_size=0
    local ram_info=$(sudo dmidecode --type 17)
    while IFS= read -r line; do
        if [[ $line =~ "Manufacturer:" ]]; then
            manufacturer=$(echo "$line" | awk -F ':' '{print $2}' | sed -e 's/^[[:space:]]*//')
        elif [[ $line =~ "Part Number:" ]]; then
            part_number=$(echo "$line" | awk -F ':' '{print $2}' | sed -e 's/^[[:space:]]*//')
        elif [[ $line =~ "Size:" ]]; then
            size=$(echo "$line" | awk -F ':' '{print $2}' | sed -e 's/^[[:space:]]*//')
            total_size=$((total_size + size))
        elif [[ $line =~ "Speed:" ]]; then
            speed=$(echo "$line" | awk -F ':' '{print $2}' | sed -e 's/^[[:space:]]*//')
        elif [[ $line =~ "Locator:" ]]; then
            location=$(echo "$line" | awk -F ':' '{print $2}' | sed -e 's/^[[:space:]]*//')
            echo "$manufacturer    $part_number    $size    $speed    $location"
        fi
    done <<< "$ram_info"
    echo "-------------------------------------------------------------------------"
    echo "Total Installed RAM: $total_size GB"
}

# Function to display the video report
videoreport() {
    echo "Video Report"
    echo "------------"
    echo "Video Card/Chipset Manufacturer: $(lspci | grep -i 'VGA compatible controller' | awk -F ':' '{print $3}' | sed -e 's/^[[:space:]]*//')"
    echo "Video Card/Chipset Model: $(lspci | grep -i 'VGA compatible controller' | awk -F ':' '{print $4}' | sed -e 's/^[[:space:]]*//')"
}

# Function to display the disk report
diskreport() {
    echo "Disk Report"
    echo "-----------"
    echo "Manufacturer    Model        Size    Partition    Mount Point    Filesystem Size    Free Space"
    echo "------------------------------------------------------------------------------------------------"
    local disk_info=$(lsblk -o NAME,SIZE,VENDOR,MODEL | grep -v "loop" | grep -v "sr0")
    while IFS= read -r line; do
        local disk_name=$(echo "$line" | awk '{print $1}')
        local disk_size=$(echo "$line" | awk '{print $2}')
        local disk_vendor=$(echo "$line" | awk '{print $3}')
        local disk_model=$(echo "$line" | awk '{print $4}')
        local partition_info=$(lsblk -o NAME,MOUNTPOINT,FSTYPE,SIZE -n -r "/dev/$disk_name" 2>/dev/null)
        while IFS= read -r partition_line; do
            local partition_name=$(echo "$partition_line" | awk '{print $1}')
            local mount_point=$(echo "$partition_line" | awk '{print $2}')
            local filesystem_type=$(echo "$partition_line" | awk '{print $3}')
            local partition_size=$(echo "$partition_line" | awk '{print $4}')
            local partition_free_space=$(df -h --output=avail "/dev/$partition_name" 2>/dev/null | tail -n 1)
            echo "$disk_vendor    $disk_model    $disk_size    $partition_name    $mount_point    $filesystem_type    $partition_size    $partition_free_space"
        done <<< "$partition_info"
    done <<< "$disk_info"
    echo "------------------------------------------------------------------------------------------------"
}

# Function to display the network report
networkreport() {
    echo "Network Report"
    echo "--------------"
    echo "Manufacturer    Model/Description    Link State    Current Speed    IP Addresses    Bridge Master    DNS Servers    Search Domains"
    echo "-----------------------------------------------------------------------------------------------------------------------------"
    local network_info=$(sudo lshw -C network 2>/dev/null)
    while IFS= read -r line; do
        if [[ $line =~ "description:" ]]; then
            description=$(echo "$line" | awk -F ':' '{print $2}' | sed -e 's/^[[:space:]]*//')
        elif [[ $line =~ "product:" ]]; then
            product=$(echo "$line" | awk -F ':' '{print $2}' | sed -e 's/^[[:space:]]*//')
        elif [[ $line =~ "logical name:" ]]; then
            logical_name=$(echo "$line" | awk -F ':' '{print $2}' | sed -e 's/^[[:space:]]*//')
            local link_state=$(cat "/sys/class/net/$logical_name/operstate")
            local current_speed=$(ethtool "$logical_name" 2>/dev/null | grep "Speed:" | awk '{print $2}')
            local ip_addresses=$(ip -4 -o addr show "$logical_name" | awk '{print $4}')
            local bridge_master=$(brctl show | grep -w "$logical_name" | awk '{print $1}')
            local dns_servers=$(nmcli dev show "$logical_name" | grep "DNS" | awk '{print $2}')
            local search_domains=$(nmcli dev show "$logical_name" | grep "DOMAINS" | awk '{print $2}')
            echo "$description    $product    $link_state    $current_speed    $ip_addresses    $bridge_master    $dns_servers    $search_domains"
        fi
    done <<< "$network_info"
    echo "-----------------------------------------------------------------------------------------------------------------------------"
}
