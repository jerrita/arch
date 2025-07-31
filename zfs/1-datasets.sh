#!/usr/bin/bash
zfs create -o mountpoint=none zpool/data
zfs create -o mountpoint=none zpool/ROOT
zfs create -o mountpoint=/ -o canmount=noauto zpool/ROOT/default
zfs create -o mountpoint=/home zpool/data/home
zfs create -o mountpoint=/root zpool/data/home/root
