#!/bin/bash

# Function to display the RAM report
ramreport() {
    echo "RAM Report"
    echo "----------"
    echo "Manufacturer    Model/Name    Size    Speed    Location"
    echo "-----------------------------------------------------"

    # Get the RAM information using dmidecode
    local ram_info=$(sudo dmidecode -t memory 2>/dev/null)

    local total_size=0

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

    echo "-----------------------------------------------------"
    echo "Total Installed RAM: $total_size GB"
}

# Example usage:
ramreport
