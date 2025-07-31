sudo pacman -S pipewire-alsa pipewire-pulse alsa-firmware alsa-ucm-conf
systemctl --user enable --now pipewire pipewire-pulse
