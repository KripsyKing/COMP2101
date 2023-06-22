#!/bin/bash

# Function to convert bytes to human-friendly format
human_readable() {
    awk -v bytes="${1}" 'BEGIN {
        units["B"] = 0;
        units["KB"] = 1;
        units["MB"] = 2;
        units["GB"] = 3;
        units["TB"] = 4;
        unit = "B";
        size = bytes;
        for (i = 0; size >= 1024 && i < 4; i++) {
            size = size / 1024;
            unit = "KB MB GB TB"[i + 1];
        }
        printf "%.2f %s", size, unit;
    }'
}

# Get the disk drive information using 'lsblk' command
drive_info=$(lsblk -b -o NAME,TYPE,MODEL,SIZE,MOUNTPOINT,FSTYPE,FSSIZE,FSUSED,FSAVAIL | tail -n +2)

# Print the report title
echo "Disk Drive Report"
echo "-----------------"
echo

# Print the table header
printf "%-10s %-10s %-20s %-15s %-10s %-15s %-15s\n" "Drive" "Type" "Model" "Size" "Partition" "Mount Point" "Free Space"
echo "------------------------------------------------------------------------------------"

# Loop through the drive information and print the table rows
while read -r drive type model size mountpoint fstype fssize fsused fsavail; do
    # Convert the drive size to a human-friendly format
    size_human=$(human_readable "$size")

    # Check if the drive is mounted
    if [[ -n "$mountpoint" ]]; then
        # Convert the filesystem size and free space to human-friendly formats
        fssize_human=$(human_readable "$fssize")
        fsavail_human=$(human_readable "$fsavail")

        # Print the mounted drive information
        printf "%-10s %-10s %-20s %-15s %-10s %-15s %-15s\n" "$drive" "$type" "$model" "$size_human" "$mountpoint" "$fssize_human" "$fsavail_human"
    else
        # Print the unmounted drive information
        printf "%-10s %-10s %-20s %-15s %-10s %-15s %-15s\n" "$drive" "$type" "$model" "$size_human" "-" "-" "-"
    fi
done <<< "$drive_info"
