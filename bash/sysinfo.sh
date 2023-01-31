#!/bash/bin
# Author : Michael Major 200422012
# Title : Challenge Script ( system info )
# Discription : This script allows the use to gain some system information

# Start of script
# Displaying domain name
echo -n 'FQDN: '
hostname

# Displaying operating system information
echo 'System Info:'
hostnamectl | grep -v 'Hardware'

# Displaying the main ip address used
echo 'IP Addresses:'
ip address | grep -w inet | grep -v 127

# Displaying file system status 
echo 'Root Filesystem Status:'
df -h /
