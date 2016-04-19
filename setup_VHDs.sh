#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

# If this is a new virtual HD, then create an msdos partition table.
# TODO: write a switch to use gpt partition table if hard drive > 2GB.
if ! parted /dev/sdb print | grep msdos; then
    parted /dev/sdb mklabel msdos
fi

# Setup NIDS partitions each with PER sizes.

# PER0=0
# PER1=10  # 10% pbf file
# PER2=20  # 10% flat nodes
# PER3=50  # 30% main-data
# PER4=55  #  5% main-index
# PER5=70  # 30% slim-data
# PER6=100 # 30% slim-index
PER=(0 10 20 50 55 70 100)
NIDS=(1 2 3 4 5 6)

for ID in ${NIDS}; do
    if [[ ! -b /dev/sdb${ID} ]]; then
        parted /dev/sdb mkpart primary ${PER[${ID}-1]}% ${PER[${ID}]}%
        mkfs.ext4 /dev/sdb${ID}
    fi
    mkdir -p /mnt/vssd${ID}
    if ! grep "/dev/sdb${ID}" /etc/fstab; then
        echo "/dev/sdb${ID} /mnt/vssd${ID}   ext4   defaults   0   0" >> /etc/fstab
    fi
    if ! grep -qs "/mnt/vssd${ID}" /proc/mounts; then
        mount /mnt/vssd${ID}
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


