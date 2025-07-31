LINUX_NAME=linux-6.9.7.arch1-1
HEADER_NAME=linux-headers-6.9.7.arch1-1
LINUX_URL=https://archive.archlinux.org/packages/l/linux/${LINUX_NAME}-x86_64.pkg.tar.zst
HEADER_URL=https://archive.archlinux.org/packages/l/linux-headers/${HEADER_NAME}-x86_64.pkg.tar.zst


checker() {
	read -p "Stage at $1, Continue? [Y/n]: " choice
	if [ "$choice" == "n" ]
	then
		exit
	fi
}

# Time
timedatectl set-ntp true

# Update Keyring
# pacman -Sy archlinux-keyring && pacman -Su


# Install
checker "Pacstrap system"
sed -i '1iServer = https:\/\/mirrors.sustech.edu.cn\/archlinux\/$repo\/os\/$arch' /etc/pacman.d/mirrorlist
vim /etc/pacman.d/mirrorlist
pacstrap -K /mnt base linux-firmware vim

# Localize
checker "Generate fs table"
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab

# Network
ip a
read -p "Input your nic name for DHCP: " nicname

# Change root and install
checker "Change root and install"
read -p "Input your hostname: " hostname
read -p "Input your username: " username

cp x-keys.sh /mnt/root
cat>/mnt/root/nextstep-1<<EOF
checker() {
        read -p "Stage at \$1, Continue? [Y/n]: " choice
        if [ "\$choice" == "n" ]
        then
                exit
        fi
}

checker "Populate linux"
curl -fsSLO $LINUX_URL
curl -fsSLO $HEADER_URL
pacman -U linux-*

ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc

# Change locale
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
sed -i 's/^#zh-CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf

echo $hostname > /etc/hostname
echo '
127.0.0.1        localhost
::1              localhost
127.0.1.1        ${hostname}.domain $hostname
' > /etc/hosts
cat /etc/hosts

echo "Changing root passwd..."
passwd

echo 'Setting ${nicname}...'
echo '
[Match]
Name = ${nicname}

[Network]
DHCP = yes
' > /etc/systemd/network/10-wired.network

echo Please update mkinitcpio and do nextstep-2
EOF

cat << EOF > /mnt/root/nextstep-2
checker() {
	read -p "Stage at $1, Continue? [Y/n]: " choice
	if [ "$choice" == "n" ]
	then
		exit
	fi
}

echo "Populating keys..."
bash x-keys.sh

checker "Install bootloader and other packs"
pacman -Sy
pacman -S grub efibootmgr openssh git base-devel os-prober sudo zfs-linux

echo 'Enabling services...'
zpool set cachefile=/etc/zfs/zpool.cache zpool
systemctl enable sshd systemd-networkd
systemctl enable zfs.target zfs-import-cache.service zfs-mount.service zfs-import.target

zgenhostid \$(hostid)

checker "Install Grub"
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Arch
grub-mkconfig -o /boot/grub/grub.cfg
mkinitcpio -P

checker "Create user"
useradd -mG wheel $username
passwd $username

echo 'Making sudo works...'
sed -i 's/^# \(%wheel.*NOPASSWD.*\)/\1/' /etc/sudoers

echo "Now you can modify yourself and reboot."
echo "If you install it on real machine, remember install intel-ucode or amd-ucode"
EOF

echo "Now you can goto /root and bash nextstep."
arch-chroot /mnt
