#!/bin/bash

diskreport() {
  echo "Disk Report"
  echo "-----------"
  echo

  echo "Drive Manufacturer | Drive Model | Drive Size | Partition | Mount Point | Filesystem Size | Free Space"
  echo "------------------ | ----------- | ---------- | --------- | ----------- | --------------- | -----------"

  # Get disk information using 'lsblk' command
  disks=$(lsblk -o NAME,MODEL,SIZE,MOUNTPOINT,FSTYPE,FSSIZE,FSUSED --exclude 1,7 -n -r)

  while IFS=' ' read -r name model size mountpoint fstype fssize fsused; do
    # Format disk size
    size_human=$(numfmt --to=iec-i --suffix=B --format="%.1f" <<< "$size")

    # Format filesystem size and free space if mounted
    if [ -n "$mountpoint" ]; then
      fssize_human=$(numfmt --to=iec-i --suffix=B --format="%.1f" <<< "$fssize")
      fsused_human=$(numfmt --to=iec-i --suffix=B --format="%.1f" <<< "$fsused")
    else
      fssize_human="N/A"
      fsused_human="N/A"
    fi

    echo "$name | $model | $size_human | $mountpoint | $fstype | $fssize_human | $fsused_human"
  done <<< "$disks"
}

# Call the diskreport function
diskreport
