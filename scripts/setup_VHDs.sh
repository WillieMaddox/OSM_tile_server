#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

# Setup NIDS partitions each with PER sizes.

# PER0=0
# PER1=10  # 10% pbf file
# PER2=20  # 10% flat nodes
# PER3=50  # 30% main-data
# PER4=55  #  5% main-index
# PER5=70  # 30% slim-data
# PER6=100 # 30% slim-index
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
    mkdir -p /mnt/${DEV}${ID}
    if ! grep "/dev/${DEV}${ID}" /etc/fstab; then
        echo "/dev/${DEV}${ID} /mnt/${DEV}${ID}   ext4   defaults   0   0" >> /etc/fstab
    fi
    if ! grep -qs "/mnt/${DEV}${ID}" /proc/mounts; then
        mount /mnt/${DEV}${ID}
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
    mkdir -p /mnt/${DEV}${ID}
    if ! grep "/dev/${DEV}${ID}" /etc/fstab; then
        echo "/dev/${DEV}${ID} /mnt/${DEV}${ID}   ext4   defaults   0   0" >> /etc/fstab
    fi
    if ! grep -qs "/mnt/${DEV}${ID}" /proc/mounts; then
        mount /mnt/${DEV}${ID}
    fi
done

# ID=1
# if [[ ! -b /dev/sdb${ID} ]]; then
#     parted /dev/sdb mkpart primary ${PER[${ID}-1]}% ${PER[${ID}]}%
#     mkfs.ext4 /dev/sdb${ID}
# fi
# mkdir -p /mnt/vssd${ID}
# if ! grep "/dev/sdb${ID}" /etc/fstab; then
#     echo "/dev/sdb${ID} /mnt/vssd${ID}   ext4   defaults   0   0" >> /etc/fstab
# fi
# if ! grep -qs "/mnt/vssd${ID}" /proc/mounts; then
#     mount /mnt/vssd${ID}
# fi
#
# ID=2
# if [[ ! -b /dev/sdb${ID} ]]; then
#     parted /dev/sdb mkpart primary ${PER[${ID}-1]}% ${PER[${ID}]}%
#     mkfs.ext4 /dev/sdb${ID}
# fi
# mkdir -p /mnt/vssd${ID}
# if ! grep "/dev/sdb${ID}" /etc/fstab; then
#     echo "/dev/sdb${ID} /mnt/vssd${ID}   ext4   defaults   0   0" >> /etc/fstab
# fi
# if ! grep -qs "/mnt/vssd${ID}" /proc/mounts; then
#     mount /mnt/vssd${ID}
# fi
#
# ID=3
# if [[ ! -b /dev/sdb${ID} ]]; then
#     parted /dev/sdb mkpart primary ${PER[${ID}-1]}% ${PER[${ID}]}%
#     mkfs.ext4 /dev/sdb${ID}
# fi
# mkdir -p /mnt/vssd${ID}
# if ! grep "/dev/sdb${ID}" /etc/fstab; then
#     echo "/dev/sdb${ID} /mnt/vssd${ID}   ext4   defaults   0   0" >> /etc/fstab
# fi
# if ! grep -qs "/mnt/vssd${ID}" /proc/mounts; then
#     mount /mnt/vssd${ID}
# fi
#
# ID=4
# if [[ ! -b /dev/sdb${ID} ]]; then
#     parted /dev/sdb mkpart primary ${PER[${ID}-1]}% ${PER[${ID}]}%
#     mkfs.ext4 /dev/sdb${ID}
# fi
# mkdir -p /mnt/vssd${ID}
# if ! grep "/dev/sdb${ID}" /etc/fstab; then
#     echo "/dev/sdb${ID} /mnt/vssd${ID}   ext4   defaults   0   0" >> /etc/fstab
# fi
# if ! grep -qs "/mnt/vssd${ID}" /proc/mounts; then
#     mount /mnt/vssd${ID}
# fi


