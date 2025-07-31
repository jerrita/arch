#!/usr/bin/bash
zpool create -f -o ashift=12  \
    -O acltype=posixacl       \
    -O atime=off              \
    -O xattr=sa               \
    -O dnodesize=legacy       \
    -O normalization=formD    \
    -O mountpoint=none        \
    -O canmount=off           \
    -O devices=off            \
    -R /mnt                   \
    -o autotrim=on zpool $@
