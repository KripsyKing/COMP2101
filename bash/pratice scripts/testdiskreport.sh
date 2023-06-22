#!/bin/bash

# Function to display the disk report
diskreport() {
    echo " "
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


# Generate disk report
diskreport
