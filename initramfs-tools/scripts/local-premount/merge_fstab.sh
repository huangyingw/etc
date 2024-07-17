#!/bin/sh
# This script will run before mounting the root filesystem

# Merge fstab.common and fstab.local into fstab
cat /etc/fstab_repo/fstab.common /etc/fstab.local > /etc/fstab
