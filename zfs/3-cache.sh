#!/usr/bin/bash
zpool set cachefile=/etc/zfs/zpool.cache zpool
mkdir -p /mnt/etc/zfs
cp /etc/zfs/zpool.cache /mnt/etc/zfs
