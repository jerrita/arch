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

# Format (BIOS/MBR: single ext4 partition)
checker "Format disk"
mkfs.ext4 ${diskname}1

checker "Mount disk"
mount ${diskname}1 /mnt

# Update Keyring
# pacman -Sy archlinux-keyring && pacman -Su

# Install
checker "Pacstrap system"
sed -i '1iServer = http:\/\/mirrors.sustech.edu.cn\/archlinux\/$repo\/os\/$arch' /etc/pacman.d/mirrorlist
vim /etc/pacman.d/mirrorlist
pacstrap /mnt base linux vim

# Localize
checker "Generate fs table"
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab

# Network (dhcp on all interfaces)
# ip a

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
pacman -S grub openssh git sudo qemu-guest-agent

echo 'Enabling services...'
systemctl enable sshd systemd-networkd qemu-guest-agent

echo 'Setting up DHCP on all interfaces...'
cat > /etc/systemd/network/90-dhcp.network <<EOF
[Match]
Name=*

[Network]
DHCP=yes
EOF

checker "Install grub"
grub-install --target=i386-pc ${diskname}
grub-mkconfig -o /boot/grub/grub.cfg

checker "Create user"
useradd -mG wheel $username
passwd $username

echo 'Making sudo works...'
sed -i 's/^# \(%wheel.*NOPASSWD.*\)/\1/' /etc/sudoers

echo "Now you can modify yourself and reboot."
EOF
echo "Now you can goto /root and bash nextstep."
arch-chroot /mnt
