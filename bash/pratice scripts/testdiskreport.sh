#!/bin/bash

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
diskreport
