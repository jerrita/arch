checker() {
	read -p "Stage at $1, Continue? [Y/n]: " choice
	if [ "$choice" == "n" ]
	then
		exit
	fi
}

echo "Arch Installer -- btrfs"

# Time
timedatectl set-ntp true

# Disks
lsblk
read -p "Input your disk: " diskname
cfdisk $diskname

# Format
checker "Format & Mount disk"
mkfs.vfat -n BOOT ${diskname}p1
mkfs.btrfs -L arch-btrfs ${diskname}p2 -f

echo "=> Creating subvols..."
mount --mkdir ${diskname}p2 /tmp/btrfs-full
btrfs subvol create /tmp/btrfs-full/@
btrfs subvol create /tmp/btrfs-full/@home
btrfs subvol create /tmp/btrfs-full/@swap
btrfs subvol create /tmp/btrfs-full/@var-tmp
btrfs subvol create /tmp/btrfs-full/@var-cache
chattr +C /tmp/btrfs-full/@swap
chattr +C /tmp/btrfs-full/@var-cache
umount /tmp/btrfs-full
echo "=> Mounting..."
mount --mkdir ${diskname}p2 -o subvol=@ /mnt
mount --mkdir ${diskname}p2 -o subvol=@home /mnt/home
mount --mkdir ${diskname}p2 -o subvol=@swap /mnt/swap
mount --mkdir ${diskname}p2 -o subvol=@var-tmp /mnt/var/tmp
mount --mkdir ${diskname}p2 -o subvol=@var-cache /mnt/var/cache
mkdir -p /mnt/boot/efi
mount ${diskname}p1 /mnt/boot/efi

# Update Keyring
# pacman -Sy archlinux-keyring && pacman -Su

# Install
checker "Pacstrap system"
sed -i '1iServer = https:\/\/mirrors.sustech.edu.cn\/archlinux\/$repo\/os\/$arch' /etc/pacman.d/mirrorlist
vim /etc/pacman.d/mirrorlist
pacstrap /mnt base linux linux-firmware vim btrfs-progs

read -p "Input extra packages you want to install (e.g. intel-ucode): " extras

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
sed -i 's/^#zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/g' /etc/locale.gen
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
pacman -S grub efibootmgr openssh git base-devel os-prober sudo zsh $extras

echo 'Setting ${nicname}...'
echo '
[Match]
Name = $nicname

[Network]
DHCP = yes
' > /etc/systemd/network/10-wired.network

echo 'Enabling services...'
systemctl enable sshd systemd-networkd

checker "Install grub"
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Arch
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
