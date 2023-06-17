#!/bin/bash

# Function to convert bytes to human-friendly format
format_size() {
    local size=$1

    if (( size < 1024 )); then
        echo "${size}B"
    elif (( size < 1024 * 1024 )); then
        echo "$(( size / 1024 ))KB"
    elif (( size < 1024 * 1024 * 1024 )); then
        echo "$(( size / 1024 / 1024 ))MB"
    else
        echo "$(( size / 1024 / 1024 / 1024 ))GB"
    fi
}

# Function to display the RAM report
ramreport() {
    echo "RAM Report"
    echo "----------"
    echo "Manufacturer    Model/Name    Size    Speed    Location"
    echo "-----------------------------------------------------"

    local total_size=0

    # Get the RAM information from sysfs
    for ram_dir in /sys/devices/system/edac/mc/*/csrow*/; do
        local manufacturer=$(cat "$ram_dir/dimm_manufacturer" 2>/dev/null)
        local model=$(cat "$ram_dir/dimm_part_number" 2>/dev/null)
        local size=$(cat "$ram_dir/dimm_size" 2>/dev/null)
        local speed=$(cat "$ram_dir/dimm_speed" 2>/dev/null)
        local location=$(cat "$ram_dir/dimm_location" 2>/dev/null)

        if [[ -n $manufacturer && -n $model && -n $size && -n $speed && -n $location ]]; then
            local formatted_size=$(format_size "$size")
            total_size=$((total_size + size))

            echo "$manufacturer    $model    $formatted_size    $speed    $location"
        fi
    done

    local formatted_total_size=$(format_size "$total_size")
    echo "-----------------------------------------------------"
    echo "Total Installed RAM: $formatted_total_size"
}

# Example usage:
ramreport
