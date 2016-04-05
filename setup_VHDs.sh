#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

# If this is a new virtual HD, then create an msdos partition table.
# TODO: write a switch to use gpt partition table if hard drive > 2GB.
if ! parted /dev/sdb print | grep msdos; then
    parted /dev/sdb mklabel msdos
fi

# Setup 4 different tablespaces each on their own virtual HD.

if [[ ! -b /dev/sdb1 ]]; then
    parted /dev/sdb mkpart primary 0 80%
    mkfs.ext4 /dev/sdb1
fi
if [[ ! -d /mnt/vssd1 ]]; then
    mkdir /mnt/vssd1
fi
if ! grep '/dev/sdb1' /etc/fstab; then
    echo '/dev/sdb1 /mnt/vssd1   ext4   defaults   0   0' >> /etc/fstab
fi
if ! grep -qs '/mnt/vssd1' /proc/mounts; then
    mount /mnt/vssd1
fi
if [[ ! -d /mnt/vssd1/vssd ]]; then
    mkdir /mnt/vssd1/vssd
fi
chown postgres -R /mnt/vssd1/vssd


if [[ ! -b /dev/sdb2 ]]; then
    parted /dev/sdb mkpart primary 80% 100%
    mkfs.ext4 /dev/sdb2
fi
if [[ ! -d /mnt/vssd2 ]]; then
    mkdir /mnt/vssd2
fi
if ! grep '/dev/sdb2' /etc/fstab; then
    echo '/dev/sdb2 /mnt/vssd2   ext4   defaults   0   0' >> /etc/fstab
fi
if ! grep -qs '/mnt/vssd2' /proc/mounts; then
    mount /mnt/vssd2
fi
if [[ ! -d /mnt/vssd2/vssd ]]; then
    mkdir /mnt/vssd2/vssd
fi
chown postgres -R /mnt/vssd2/vssd


# if [[ ! -b /dev/sdb3 ]]; then
#     parted /dev/sdb mkpart primary 54% 100%
#     mkfs.ext4 /dev/sdb3
# fi
# if [[ ! -d /mnt/vssd3 ]]; then
#     mkdir /mnt/vssd3
# fi
# if ! grep '/dev/sdb3' /etc/fstab; then
#     echo '/dev/sdb3 /mnt/vssd3   ext4   defaults   0   0' >> /etc/fstab
# fi
# if ! grep -qs '/mnt/vssd3' /proc/mounts; then
#     mount /mnt/vssd3
# fi
# if [[ ! -d /mnt/vssd3/vssd ]]; then
#     mkdir /mnt/vssd3/vssd
# fi
# chown postgres -R /mnt/vssd3/vssd


# if [[ ! -b /dev/sdb4 ]]; then
#     parted /dev/sdb mkpart primary 75% 100%
#     mkfs.ext4 /dev/sdb4
# fi
# if [[ ! -d /mnt/vssd4 ]]; then
#     mkdir /mnt/vssd4
# fi
# if ! grep '/dev/sdb4' /etc/fstab; then
#     echo '/dev/sdb4 /mnt/vssd4   ext4   defaults   0   0' >> /etc/fstab
# fi
# if ! grep -qs '/mnt/vssd4' /proc/mounts; then
#     mount /mnt/vssd4
# fi
# if [[ ! -d /mnt/vssd4/vssd ]]; then
#     mkdir /mnt/vssd4/vssd
# fi
# chown postgres -R /mnt/vssd4/vssd


