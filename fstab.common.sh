#!/bin/zsh
SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd "$SCRIPTPATH"

/etc/initramfs-tools/scripts/local-premount/merge_fstab.sh
