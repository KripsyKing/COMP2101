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
    echo " "
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
    echo " "
    echo "Computer Report"
    echo "---------------"
    echo "Manufacturer: $(sudo dmidecode -s system-manufacturer)"
    echo "Description or Model: $(sudo dmidecode -s system-product-name)"
    echo "Serial Number: $(sudo dmidecode -s system-serial-number)"
}

# Function to display the OS report
osreport() {
    echo " "
    echo "OS Report"
    echo "---------"
    echo "Linux Distro: $(lsb_release -sd)"
    echo "Distro Version: $(lsb_release -sr)"
    
}

# Function to display the RAM report
ramreport() {
    echo " "
    echo "RAM Report"
    echo "----------"
    echo "Component Manufacturer    Model                  Size    Speed    Location"
    echo " "
    local total_size=0
    local ram_info=$(sudo dmidecode --type 17)
    while IFS= read -r line; do
        if [[ $line =~ "Manufacturer:" ]]; then
            manufacturer=$(echo "$line" | awk -F ':' '{print $2}' | sed -e 's/^[[:space:]]*//')
        elif [[ $line =~ "Part Number:" ]]; then
            part_number=$(echo "$line" | awk -F ':' '{print $2}' | sed -e 's/^[[:space:]]*//')
        elif [[ $line =~ "Size:" ]]; then
            size=$(echo "$line" | awk -F ':' '{print $2}' | sed -e 's/^[[:space:]]*//')
            IFS=" "
	    read -a size_number <<< "$size"
            total_size=$((total_size + size_number))
        elif [[ $line =~ "Speed:" ]]; then
            speed=$(echo "$line" | awk -F ':' '{print $2}' | sed -e 's/^[[:space:]]*//')
        elif [[ $line =~ "Bank Locator:" ]]; then
            location=$(echo "$line" | awk -F ':' '{print $2}' | sed -e 's/^[[:space:]]*//')
            echo "$manufacturer    $part_number    $size    $speed    $location"
        fi
    done <<< "$ram_info"
    echo "-------------------------------------------------------------------------"
    echo "Total Installed RAM: $total_size GB"
}

# Function to display the video report
videoreport() {
    echo " "
    echo "Video Report"
    echo "------------"
    echo "Video Card/Chipset Manufacturer: $(lspci | grep -i 'VGA compatible controller' | awk -F ':' '{print $3}' | sed -e 's/^[[:space:]]*//')"
    echo "Video Card/Chipset Model: $(lspci | grep -i 'VGA compatible controller' | awk -F ':' '{print $4}' | sed -e 's/^[[:space:]]*//')"
    
}

# Function to display the disk report
diskreport() {
    echo " "
    echo "Disk Report"
    echo "-----------"
    local disk_info=$(lsblk -o NAME,SIZE,VENDOR,MODEL | grep -v "loop" | grep -v "sr0")
    while IFS= read -r line; do
        local disk_name=$(echo "$line" | awk '{print $1}')
        local disk_size=$(echo "$line" | awk '{print $2}')
        local disk_vendor=$(echo "$line" | awk '{print $3}')
        local disk_model=$(echo "$line" | awk '{print $4}')
        local partition_info=$(lsblk -o NAME,MOUNTPOINT,FSTYPE,SIZE -n -r "/dev/$disk_name" 2>/dev/null)
        echo "$disk_size    $disk_vendor    $disk_model"
    done <<< "$disk_info"
    echo "---------------------------------------------------"
}

# Function to display the network report
networkreport() {
    echo " "
    echo "Network Report"
    echo "--------------"
    echo "Manufacturer    Model/Description    Link State    Current Speed    IP Addresses    Bridge Master    DNS Servers    Search Domains"
    echo " "
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

# Function to display the help message
display_help() {
    echo "Usage: ./systeminfo.sh [OPTIONS]"
    echo "Options:"
    echo "  -h    Display this help message and exit"
    echo "  -v    Run the script verbosely, showing errors to the user"
    echo "  -system    Run only the computerreport, osreport, cpureport, ramreport, and videoreport"
    echo "  -disk    Run only the diskreport"
    echo "  -network    Run only the networkreport"
}

# Check if the user is running the script as root
if [[ $EUID -ne 0 ]]; then
    errormessage "This script must be run as root."
    exit 1
fi

# Default values
verbose=false
run_system=false
run_disk=false
run_network=false

# Process command line options
while getopts "hvsystemdisknetwork" opt; do
    case ${opt} in
        h)
            display_help
            exit 0
            ;;
        v)
            verbose=true
            ;;
        s)
            run_system=true
            ;;
        d)
            run_disk=true
            ;;
        n)
            run_network=true
            ;;
        *)
            display_help
            exit 1
            ;;
    esac
done

# Run the appropriate reports based on the command line options
if [[ "$run_system" == true ]]; then
    computerreport
    osreport
    cpureport
    ramreport
    videoreport
elif [[ "$run_disk" == true ]]; then
    diskreport
elif [[ "$run_network" == true ]]; then
    networkreport
else
    computerreport
    osreport
    cpureport
    ramreport
    videoreport
    diskreport
    networkreport
fi
