if cat /etc/pacman.conf | grep "archlinuxcn" > /dev/null
then
echo "Aur repo exists. Exit."
else
cat<<EOF>>/etc/pacman.conf
[archlinuxcn]
Server = https://mirrors.cqupt.edu.cn/archlinuxcn
EOF
pacman -Syy
fi

git clone https://aur.archlinux.org/yay.git /opt/yay
cd /opt/yay && makepkg -si
