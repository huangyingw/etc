#!/bin/sh
# This script will run before mounting the root filesystem

# Check if /etc/fstab.local exists
if [ ! -f /etc/fstab.local ]; then
  # If /etc/fstab.local does not exist, copy the current /etc/fstab to /etc/fstab.local
  cp /etc/fstab /etc/fstab.local
fi

# Merge fstab.common and fstab.local into fstab
cat /etc/fstab.local /etc/fstab_repo/fstab.common > /etc/fstab

# Log the merge process
echo "Merged fstab at $(date)" >> /var/log/merge_fstab.log
