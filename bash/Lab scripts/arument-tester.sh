#!/bin/bash

#####
# Defaults
#####

filename=~
verbose=no

#####
# Command Line Processing
#####

while [ $# -gt 0 ]; do
	case "$1" in
		-h | --help )
			cat <<EOF

Usage: $(basename $0) [-h|--help] [-v|--verbose] [-f file]
This script tells you what is going on if you use the verbose mode.
The default filename to work on is your home directory unless you specify a different file with -f

EOF
			exit
			;;
		-v | --verbose)
			verbose=yes
			;;
		-f )
			shift
			if [ -n "$1" ]; then 
				filename="$1"
			else
				echo "You need to give me a filename with -f"
				exit 1
			fi
			;;
		* )
			echo "Unrecognized argument '$1'"
			exit 1
			;;
		esac
	shift
done

#####
# Main work of script
#####
[ "$verbose" = "yes" ] && echo Processed command line, ready to do more things
[ "$verbose" = "yes" ] && echo verbose mode is set to $verbose
[ "$verbose" = "yes" ] && echo filename is $filename
