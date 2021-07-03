if cat /etc/pacman.conf | grep "archlinuxcn" > /dev/null
then
cat<<EOF>>/etc/pacman.conf
[archlinuxcn]
Server = https://mirrors.cqupt.edu.cn/archlinuxcn
EOF
pacman -Syy
fi

pacman -Syu haveged
systemctl start haveged
systemctl enable haveged

rm -fr /etc/pacman.d/gnupg
pacman-key --init
pacman-key --populate archlinux
pacman-key --populate archlinuxcn

pacman -S yay
