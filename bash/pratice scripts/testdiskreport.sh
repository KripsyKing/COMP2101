#!/bin/bash

diskreport() {
    # Title
    echo "Disk Report"

    # Column headers
    printf "%-20s %-20s %-20s %-15s %-15s %-20s %-20s\n" \
        "Drive Manufacturer" "Drive Model" "Drive Size" "Partition" \
        "Mount Point" "Filesystem Size" "Free Space"

    # Iterate over disks
    for disk in $(lsblk -ndo NAME,TYPE | awk '$2=="disk" {print $1}')
    do
        # Get disk info
        manufacturer=$(hdparm -I "/dev/$disk" | awk -F': ' '/^Model/ {print $2}')
        model=$(hdparm -I "/dev/$disk" | awk -F': ' '/^Device/ {print $2}')
        size=$(lsblk -nbdo SIZE "/dev/$disk")
        partitions=$(lsblk -ndo NAME,TYPE "/dev/$disk" | awk '$2=="part" {print $1}')

        # Iterate over partitions
        for partition in $partitions
        do
            mountpoint=$(lsblk -ndo MOUNTPOINT "/dev/$partition")
            filesystem=$(lsblk -ndo FSTYPE "/dev/$partition")

            if [ -n "$mountpoint" ] && [ -n "$filesystem" ]
            then
                fs_size=$(df -h | awk -v partition="/dev/$partition" '$1==partition {print $2}')
                fs_free=$(df -h | awk -v partition="/dev/$partition" '$1==partition {print $4}')
            else
                fs_size=""
                fs_free=""
            fi

            # Print partition info
            printf "%-20s %-20s %-20s %-15s %-15s %-20s %-20s\n" \
                "$manufacturer" "$model" "$size" "$partition" "$mountpoint" "$fs_size" "$fs_free"
        done
    done
}

# Generate disk report
diskreport
