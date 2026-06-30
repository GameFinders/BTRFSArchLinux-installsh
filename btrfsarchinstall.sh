#!/bin/bash
set +x
set -e

echo "Checking Internet connection [Ping target is 'kde.org']: "
ping -c 3 kde.org
pacman -Syy
pacman -S --noconfirm figlet

clear
set +x
set -e

echo "========================================================================================================================================================="
echo "Welcome to"
figlet -t -c BTRFSArch GNU+Linux
echo "                                                                                                                                 Installer Alpha 0.18-2-2"
echo "========================================================================================================================================================="
echo ""

echo "<< Available disks >>"
lsblk -d -n -o NAME,SIZE,MODEL
echo ""
read -p "Enter the drive name to install to [Example: sda, nvme0n1, sdb]: " DISK_NAME
TARGET_DISK="/dev/$DISK_NAME"

if [ ! -b "$TARGET_DISK" ]; then
    echo "[E] Target disk [$TARGET_DISK] does not exist!"
    exit 1
fi

read -p "[WARNING] This will wipe disk [$TARGET_DISK]. Proceed? [Y..N]: " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "[i] Installer aborted."
    exit 1
fi

echo "<< Partitioning Disk >>"
parted -s "$TARGET_DISK" mklabel gpt

parted -s "$TARGET_DISK" mkpart ESP fat32 1MiB 513 MiB
parted -s "$TARGET_DISK" set 1 esp on
parted -s "$TARGET_DISK" mkpart primary btrfs 513MiB 100%

if [[ "$TARGET_DISK" == *nvme* || "$TARGET_DISK" == *mmcblk* ]]; then
    BOOT_PART="${TARGET_DISK}p1"
    ROOT_PART="${TARGET_DISK}p2"
else
    BOOT_PART="${TARGET_DISK}1"
    ROOT_PART="${TARGET_DISK}2"
fi

echo "<< Formatting partitions >>"
mkfs.vfat -F 32 "$BOOT_PART"
mkfs.btrfs -f -L "BTRFSArch_RootFS" "$ROOT_PART"

echo "<< Creating BTRFS Subvolumes >>"
mount "$ROOT_PART" /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@pkg
umount /mnt

echo "<< Mounting Filesystems >>"
mount -o noatime,compress=zstd,subvol=@ "$ROOT_PART" /mnt
mkdir -p /mnt/{boot,home,var/log,var/cache/pacman/pkg}
mount -o noatime,compress=zstd,subvol=@home "$ROOT_PART" /mnt/home
mount -o noatime,compress=zstd,subvol=@log "$ROOT_PART" /mnt/var/log
mount -o noatime,compress=zstd,subvol=@pkg "$ROOT_PART" /mnt/var/cache/pacman/pkg
mount "$BOOT_PART" /mnt/boot

echo "<< Deploying System BASE >>"
pacstrap -K /mnt base linux linux-firmware btrfs-progs sudo plasma-desktop plasma-welcome kde-applications firefox networkmanager pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber plasma-login-manager discover ki18n plasma-nm flatpak

echo "<< Generating System /etc/fstab >>"
genfstab -U /mnt >> /mnt/etc/fstab

echo "<< Username & Password setup >>"
read -p " |- Username  : " NAMEUSER
read -p " |- Password  : " PASSWDUSER
read -p " |- Netw.name : " NETWORKNAME

echo "<< Auto-archchroot stage 1 >>"
echo " |- Setting timezone and clock"
arch-chroot /mnt /bin/bash <<EOF
ln -sf /usr/share/zoneinfo/Europe/Istanbul /etc/localtime
hwclock --systohc
echo "KEYMAP=trq" > /etc/vconsole.conf
echo " |- Network identity set to: $NETWORKNAME"
echo "$NETWORKNAME" > /etc/hostname

echo " |- Enabling System Daemons"
systemctl enable NetworkManager
systemctl enable plasmalogin


echo "<< Auto-archchroot stage 2 >>"
echo "root:$PASSWDUSER" | chpasswd

cat << 'EOF2' > /etc/os-release
NAME="BTRFSArch Linux"
PRETTY_NAME="BTRFSArch Linux (installed via Installer Alpha 0.18-2-2)"
ID=btrfsarchlinux
ID_LIKE=arch
BUILD_ID=rolling
ANSI_COLOR="38;2;23;147;209"
HOME_URL="about:blank"
LOGO=archlinux
EOF2

echo "<< Installing GNU GRUB >>"
pacman -S --needed --noconfirm grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id="BTRFSArch Linux"
grub-mkconfig -o /boot/grub/grub.cfg

useradd -m -G wheel -s /bin/bash "$NAMEUSER"
echo "$NAMEUSER:$PASSWDUSER" | chpasswd

mkdir -p /etc/sudoers.d
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers.d/10-installer
EOF

echo ""
echo "<< Unmounting FS >>"
umount -R /mnt

echo "==BTRFSArch GNU/Linux========================================="
echo "================================================Alpha 0.18-2-2="
echo " Installation successful"
echo ""
echo " You may now restart the system."
echo " Type in 'systemctl reboot' to restart."
echo " There Konqi is waiting."
echo " Important notices:"
echo " -> i live in Türkiye so it is set to trq as KBoard layout."
echo " -> Before using the AUR, don't as there are 1000+ Malware."
echo "    (just use flatpak bro, they are sandboxed)"
echo " -> KDE Plasma will be installed."
echo " -> GNU GRUB returned because Gummiboot refuses to systemd-boot"
echo "    so GNU GRUB is back."
echo ""
echo "=============================================================="
