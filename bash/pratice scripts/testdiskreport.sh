#!/bin/bash

<<<<<<< HEAD
# Function to display the disk report
diskreport() {
    echo " "
    echo "Disk Report"
    echo "-----------"
    echo "Manufacturer    Model        Size    Partition    Mount Point    Filesystem Size    Free Space"
    echo "------------------------------------------------------------------------------------------------"
    local disk_info=$(lsblk -o NAME,SIZE,VENDOR,MODEL | grep -v "loop" | grep -v "sr0")
    while IFS= read -r line; do
#        local disk_name=$(echo "$line" | awk '{print $1}')
#        local disk_size=$(echo "$line" | awk '{print $2}')
#        local disk_vendor=$(echo "$line" | awk '{print $3}')
#        local disk_model=$(echo "$line" | awk '{print $4}')
#        local partition_info=$(lsblk -o NAME,MOUNTPOINT,FSTYPE,SIZE -n -r "/dev/$disk_name" 2>/dev/null)
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

=======
function diskreport {
  # Print title
  echo "Disk Report"

  # Print table headers
  printf "%-20s %-20s %-20s %-20s %-20s %-20s %-20s\n" "Manufacturer" "Model" "Size" "Partition" "Mount Point" "Filesystem Size" "Free Space"

  # Iterate over each disk drive
  for drive in $(lsblk -ndo NAME,MODEL,SIZE | grep -v "loop"); do
    name=$(echo "$drive" | awk '{print $1}')
    model=$(echo "$drive" | awk '{print $2}')
    size=$(echo "$drive" | awk '{print $3}')
    partitions=$(lsblk -ndo NAME | grep "^$name")
    
    # Iterate over each partition of the drive
    for partition in $partitions; do
      mountpoint=$(lsblk -ndo MOUNTPOINT | grep "^/.*$partition$")
      filesystem_size=""
      free_space=""
      
      # Check if the partition is mounted
      if [[ -n $mountpoint ]]; then
        filesystem_size=$(df -h | grep "$partition" | awk '{print $2}')
        free_space=$(df -h | grep "$partition" | awk '{print $4}')
      fi
      
      # Print the information in the table format
      printf "%-20s %-20s %-20s %-20s %-20s %-20s %-20s\n" "$name" "$model" "$size" "$partition" "$mountpoint" "$filesystem_size" "$free_space"
    done
  done
}

# Call the diskreport function
>>>>>>> 84c7629beb91a72f98fcb51f1d19d4e5109da472
diskreport
