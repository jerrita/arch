#!/usr/bin/bash
cat << EOF >> /etc/pacman.conf
[archzfs]
Server = http://archzfs.com/\$repo/x86_64
EOF

pacman-key --recv DDF7DB817396A49B2A2723F7403BD972F75D9D76
pacman-key --lsign-key DDF7DB817396A49B2A2723F7403BD972F75D9D76
