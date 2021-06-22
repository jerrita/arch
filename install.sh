checker() {
	read -p "Stage at $1, Continue? [Y/n]: " choice
	if [ "$choice" == "n" ]
	then
		exit
	fi
}

# Time
timedatectl set-ntp true

# Disks
lsblk
read -p "Input your disk: " diskname
cfdisk $diskname

# Format
checker "Format disk"
mkfs.vfat ${diskname}1
mkfs.ext4 ${diskname}2

checker "Mount disk"
mount ${diskname}2 /mnt

# Install
checker "Pacstrap system"
sed -i '1iServer = https:\/\/mirrors.cqupt.edu.cn\/archlinux\/$repo\/os\/$arch' /etc/pacman.d/mirrorlist
vim /etc/pacman.d/mirrorlist
pacstrap /mnt base linux linux-firmware vim

# Localize
checker "Generate fs table"
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab

# Change root and install
checker "Change root and install"
read -p "Input your hostname: " hostname
read -p "Input your username: " username
cat>/mnt/root/nextstep<<EOF
checker() {
        read -p "Stage at \$1, Continue? [Y/n]: " choice
        if [ "\$choice" == "n" ]
        then
                exit
        fi
}

ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc

# Change locale
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
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

checker "Install bootloader and other packs"
pacman -S grub efibootmgr networkmanager wpa_supplicant openssh git base-devel os-prober sudo
systemctl enable NetworkManager

checker "Install grub"
mkdir /boot/efi
mount ${diskname}1 /boot/efi
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

checker "Create user"
useradd -mG wheel $username
passwd $username

echo "Now you can modify by yourself and reboot."
echo "If you install it on real machine, remember install intel_ucode or amd_ucode"
EOF
echo "Now you can goto /root and bash nextstep."
arch-chroot /mnt
