#!/bin/bash

# start of script 

# Specify the filename to check
filename="funclibary.sh"

# Get the current script's directory
script_dir=$(dirname "$(realpath "$0")")

# Build the full path to the file
file_path="$script_dir/$filename"

# Check if the file exists
if [ -e "$file_path" ]; then
    sleep 1
    echo "file located...."
    sleep 1
    echo "goodbye"
else
    echo "The function libary script is not in the same location as you are, please make sure it is in the same location."
    sleep 1
    exit 1
fi


source funclibary.sh


# Function to display the help message
display_help() {
    echo "Usage: ./systeminfo.sh [OPTIONS]"
    echo "Options:"
    echo "  -h    Display this help message and exit"
    echo "  -v    Run the script verbosely, showing errors to the user"
    echo "  -s (system)    Run only the computerreport, osreport, cpureport, ramreport, and videoreport"
    echo "  -d (disk)      Run only the diskreport"
    echo "  -n (network)   Run only the networkreport"
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
