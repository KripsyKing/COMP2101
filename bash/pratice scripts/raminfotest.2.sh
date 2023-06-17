#!/bin/bash

# Function to convert kilobytes to human-friendly format
format_size() {
    local size=$1

    if (( size < 1024 )); then
        echo "${size}KB"
    elif (( size < 1024 * 1024 )); then
        echo "$(( size / 1024 ))MB"
    else
        echo "$(( size / 1024 / 1024 ))GB"
    fi
}

# Function to display the RAM report
ramreport() {
    echo "RAM Report"
    echo "----------"
    echo "Manufacturer    Model/Name    Size    Speed    Location"
    echo "-----------------------------------------------------"

    # Get the total installed RAM size from /proc/meminfo
    local total_ram_size=$(grep -i "MemTotal:" /proc/meminfo | awk '{print $2}')
    local formatted_total_size=$(format_size "$total_ram_size")

    echo "Unknown    Unknown    $formatted_total_size    Unknown    Unknown"
    echo "-----------------------------------------------------"
    echo "Total Installed RAM: $formatted_total_size"
}

# Example usage:
ramreport
