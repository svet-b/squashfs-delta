#!/bin/bash

# Usage:
# get_delta.sh <old_squashfs_file> <new_squashfs_file> <output_delta>

xdelta3 -e -f -A -s <( unsquashfs -n -pf /dev/stdout $1 ) <( unsquashfs -n -pf /dev/stdout $2 ) $3
