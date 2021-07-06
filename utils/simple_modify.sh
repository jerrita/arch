sudo pacman -S zsh wget curl

echo "Install oh-my-zsh"
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "Install SpaceVim"
sudo pacman -S neovim
curl -sLf https://spacevim.org/install.sh | bash
