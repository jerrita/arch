#!/usr/bin/bash
umount /mnt/boot/efi
umount /mnt/boot
zfs umount -a
zfs umount zpool/ROOT/default
zpool export zpool
