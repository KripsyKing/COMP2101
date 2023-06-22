#!/bin/bash

source funclibary.sh

# start of script 


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
        s | system)
            run_system=true
            ;;
        d | disk)
            run_disk=true
            ;;
        n | network)
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
