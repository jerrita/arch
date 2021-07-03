if `whoami` = "root"
then
  echo "Please run with non-root user."
  exit
fi

if cat /etc/pacman.conf | grep "archlinuxcn" > /dev/null
then
echo "Aur repo exists. Exit."
else
cat<<EOF>>/etc/pacman.conf
[archlinuxcn]
Server = https://mirrors.cqupt.edu.cn/archlinuxcn/$arch
EOF
pacman -Syy
fi

sudo pacman -S fakeroot
sudo git clone https://aur.archlinux.org/yay.git /opt/yay
sudo chown -R ${whoami}:users /opt/yay
cd /opt/yay && makepkg -si
