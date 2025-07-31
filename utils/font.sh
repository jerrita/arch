sudo pacman -S \
    ttf-jetbrains-mono ttf-font-awesome ttf-iosevka-nerd

paru -S ttf-ms-fonts


git clone https://github.com/jerrita/fonts-apple
cd fonts-apple
make
makepkg -si
@echo "Maybe you want install otfs under pkgs"