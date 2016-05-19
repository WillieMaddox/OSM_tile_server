#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

# Setup NIDS partitions each with PER sizes.

PER=(0 50 100)
NIDS=(1 2)
DEV=sdb
# If this is a new virtual HD, then create an msdos partition table.
# TODO: write a switch to use gpt partition table if hard drive > 2GB.
if ! parted /dev/${DEV} print | grep msdos; then
    parted /dev/${DEV} mklabel msdos
fi
for ID in ${NIDS[@]}; do
    if [[ ! -b /dev/${DEV}${ID} ]]; then
        parted /dev/${DEV} mkpart primary ${PER[${ID}-1]}% ${PER[${ID}]}%
        mkfs.ext4 /dev/${DEV}${ID}
    fi
    mkdir -p /media/${DEV}${ID}
    if ! grep "/dev/${DEV}${ID}" /etc/fstab; then
        echo "/dev/${DEV}${ID} /media/${DEV}${ID}   ext4   defaults   0   0" >> /etc/fstab
    fi
    if ! grep -qs "/media/${DEV}${ID}" /proc/mounts; then
        mount /media/${DEV}${ID}
    fi
done


PER=(0 20 30 50 100)
NIDS=(1 2 3 4)
DEV=sdc
if ! parted /dev/${DEV} print | grep msdos; then
    parted /dev/${DEV} mklabel msdos
fi
for ID in ${NIDS[@]}; do
    if [[ ! -b /dev/${DEV}${ID} ]]; then
        parted /dev/${DEV} mkpart primary ${PER[${ID}-1]}% ${PER[${ID}]}%
        mkfs.ext4 /dev/${DEV}${ID}
    fi
    mkdir -p /media/${DEV}${ID}
    if ! grep "/dev/${DEV}${ID}" /etc/fstab; then
        echo "/dev/${DEV}${ID} /media/${DEV}${ID}   ext4   defaults   0   0" >> /etc/fstab
    fi
    if ! grep -qs "/media/${DEV}${ID}" /proc/mounts; then
        mount /media/${DEV}${ID}
    fi
done

