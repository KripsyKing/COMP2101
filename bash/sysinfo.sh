#!/bash/bin
# Author : Michael Major 200422012
# Title : Challenge Script ( system info )
# Discription : This script allows the user to gain some system information

# Start of script

# Title of file / start of template
echo Report for myvm
echo "======================="

# Displaying domain name

echo  FQDN: `hostname`

# Displaying Operating system and version
echo  Operating System name and version: `hostnamectl | grep -w 'Operating'`

# Displaying the main ip address used
echo IP Addresses: `hostname -I`

# Displaying file system status
echo Root Filesystem Free Space: `df -h / | awk '{print $4}' | tail -n 1`

# End of script display
echo "========================"
