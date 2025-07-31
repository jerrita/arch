#!/usr/bin/bash
zpool export zpool
zpool import zpool -R /mnt zpool -N

zfs mount zpool/ROOT/default
zfs mount -a

echo "Remember to mount your boot and efi."
