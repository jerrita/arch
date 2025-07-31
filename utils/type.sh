sudo pacman -S fcitx5-im fcitx5-rime

git clone https://github.com/jerrita/fcitx5-theme-hyacine

mkdir -p ~/.local/share/fcitx5/themes
cp -r hyacine ~/.local/share/fcitx5/themes

git clone https://github.com/boomker/rime-fast-xhup --depth=1 ~/.local/share/fcitx5/rime
