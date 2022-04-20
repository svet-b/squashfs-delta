#!/bin/bash

# Usage:
# apply_delta.sh <old_squashfs_file> <delta_file> <new_squashfs_file>

TEMP_SQPF=$(mktemp)

xdelta3 -d -s <( unsquashfs -n -pf /dev/stdout $1 ) $2 > $TEMP_SQPF

mksquashfs - $3 -pf $TEMP_SQPF -no-progress -quiet -noappend -comp xz -no-fragments

rm $TEMP_SQPF
