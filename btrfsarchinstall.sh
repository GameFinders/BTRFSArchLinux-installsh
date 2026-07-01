#!/bin/bash
set +x
set -e

echo "Checking Internet connection [Ping target is 'kde.org']: "
ping -c 3 kde.org

echo "Checking & Repopulating PACMAN: "
pacman-key --init
pacman-key --populate archlinux

echo "Installing greeter engine (Figlet): "
pacman -Syy
pacman -S --noconfirm figlet

clear
set +x
set -e

echo "========================================================================================================================================================="
echo "Welcome to"
figlet -t -s BTRFSArch GNU+Linux
echo "                                                                                                                                 Installer Alpha 0.18-3-2"
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

clear
figlet -t -s Partitioning disks
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

clear
figlet -t -s Formatting partitions
mkfs.vfat -F 32 "$BOOT_PART"
mkfs.btrfs -f -L "BTRFSArch_RootFS" "$ROOT_PART"

clear
figlet -t -s Creating BTRFS Subvolumes
mount "$ROOT_PART" /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@pkg
umount /mnt

clear
figlet -t -s Mounting filesystems
mount -o noatime,compress=zstd,subvol=@ "$ROOT_PART" /mnt
mkdir -p /mnt/{boot,home,var/log,var/cache/pacman/pkg}
mount -o noatime,compress=zstd,subvol=@home "$ROOT_PART" /mnt/home
mount -o noatime,compress=zstd,subvol=@log "$ROOT_PART" /mnt/var/log
mount -o noatime,compress=zstd,subvol=@pkg "$ROOT_PART" /mnt/var/cache/pacman/pkg
mount "$BOOT_PART" /mnt/boot

clear
figlet -t -s Desktop Environment
echo "Starting with BTRFSArch Linux Installer Alpha 0.18-3 and above, you must choose a Desktop environment so anyone who doesn't want KDE Plasma will get something else instead."
BASE_PKGS="base linux linux-firmware btrfs-progs sudo firefox networkmanager pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber flatpak"

echo ""
echo "  NO #  NAME         DESCRIPTION"
echo "     1  KDE Plasma   K Desktop Environment (version Plasma 6.7+)"
echo "     2  LXQt         Lightweight X11 Desktop Environment (Qt)"
echo "     3  LXDE         Lightweight X11 Desktop Environment (GTK2/GTK3)"
echo "     4  GNOME        Definition of bloatware"
echo "     5  Cinnamon     Cinnamon Desktop (Konsole)"
echo "     6  Cinnamon+    Cinnamon Desktop (Kitty)"
echo "     7  XFCE4        XFCE Desktop (fat little mouse)"
echo "     8  Sway TWM     Sway Tiling Window Manager"
echo " 0, 9+  TTY          No Desktop Environment (DE) or Tiling Window Manager (TWM)"
echo "=================================================================================="
read -p "   Choice : " DE_CHOICE_USER

case $DE_CHOICE_USER in
    1)
        echo "K Desktop Environment Plasma Selected"
        EXTRA_PKGS="plasma-desktop plasma-welcome kde-applications plasma-login-manager discover ki18n plasma-nm"
        DISPLAY_MGR="plasmalogin"
        DESKTOP="KDE"
        ;;
    2)
        echo "LXQt Selected"
        EXTRA_PKGS="lxqt openbox qterminal breeze-icons sddm"
        DISPLAY_MGR="sddm"
        DESKTOP="LXDE (Qt)"
        ;;
    3)
        echo "LXDE Selected"
        EXTRA_PKGS="lxde-common lxsession openbox lxde lxdm"
        DISPLAY_MGR="lxdm"
        DESKTOP="LXDE (GTK2/GTK3)"
        ;;
    4)
        echo "Definition of bloatware selected"
        EXTRA_PKGS="gnome gnome-extra gdm"
        DISPLAY_MGR="gdm"
        DESKTOP="Definition of Bloatware"
        ;;
    5)
        echo "Cinnamon w/ KDE Konsole selected"
        EXTRA_PKGS="cinnamon nemo-fileroller cinnamon-translations konsole lightdm lightdm-gtk-greeter"
        DISPLAY_MGR="lightdm"
        DESKTOP="Cinnamon"
        ;;
    6)
        echo "Cinnamon w/ Hyprland Kitty selected"
        EXTRA_PKGS="cinnamon nemo-fileroller cinnamon-translations kitty lightdm lightdm-gtk-greeter"
        DISPLAY_MGR="lightdm"
        DESKTOP="Cinnamon"
        ;;
    7)
        echo "Fat mouse selected"
        EXTRA_PKGS="xfce4 xfce4-goodies xfwm4 xfce4-panel xfdesktop xfce4-session xfce4-settings xfconf thunar xfce4-terminal xfce4-appfinder lxpolkit lightdm lightdm-gtk-greeter"
        DISPLAY_MGR="lightdm"
        DESKTOP="fat mouse"
        ;;
    8)
        echo "Sway TWM Selected"
        EXTRA_PKGS="sway swaybg swaylock swayidle waybar wofi foot wl-clipboard lightdm lightdm-gtk-greeter"
        DISPLAY_MGR="lightdm"
        DESKTOP="Sway TWM"
        ;;
    *)
        echo "TTY Selected"
        EXTRA_PKGS="lynx"
        DISPLAY_MGR=""
        DESKTOP="Text Teletype"
esac
sleep 3

clear
figlet -t -s Extra applications
echo ""
echo "  NO #  NAME                              DESCRIPTION"
echo "     1  Krita                             better than GIMP btw"
echo "     2  GNU Image Manipulation Program    Definition of bloatware"
echo "     3  Fastfetch                         Quick System Information"
echo " 0, 4+  Unlisted                          Anything unlisted"
echo "=================================================================================="
read -p "   Choice : " APP_CHOICE_USER

case $APP_CHOICE_USER in
    1)
        echo "Krita selected"
        EXTRA_PKGS_2="krita"
        ;;
    2)
        echo "GIMP selected"
        EXTRA_PKGS_2="gimp"
        ;;
    3)
        echo "System Information (fastfetch) selected"
        EXTRA_PKGS_2="fastfetch"
        ;;
    *)
        read -p "Extra packages selection [pacman]: " EXTRA_PKGS_2
        echo "Custom package or packages [$EXTRA_PKGS_2] selected."
esac
sleep 3

clear
figlet -t -s Deploying Minimal System + DE + Misc
pacstrap -K /mnt $BASE_PKGS $EXTRA_PKGS $EXTRA_PKGS_2


clear
echo "<< Generating System /etc/fstab >>"
genfstab -U /mnt >> /mnt/etc/fstab

clear
figlet -t -s Username Setup
echo "[Note: User created will be a Super user (wheel Group).]"
read -p " |- Username  : " NAMEUSER
read -p " |- Password  : " PASSWDUSER
read -p " |- Netw.name : " NETWORKNAME

clear
figlet -t -s Auto Arch-CHRoot
echo "<< Auto-archchroot stage 1 >>"
echo " |- Setting timezone and clock"
arch-chroot /mnt /bin/bash <<EOF
ln -sf /usr/share/zoneinfo/Europe/Istanbul /etc/localtime
hwclock --systohc
echo "KEYMAP=trq" > /etc/vconsole.conf
echo " |- Network identity set to: $NETWORKNAME"
echo "$NETWORKNAME" > /etc/hostname

echo " |- Installing DE [nothing may happen if none selected]"

echo " |- Enabling System Daemons"
systemctl enable NetworkManager
systemctl enable $DISPLAY_MGR

echo "<< Auto-archchroot stage 2 >>"
echo "root:$PASSWDUSER" | chpasswd

cat << 'EOF2' > /etc/os-release
NAME="BTRFSArch Linux"
PRETTY_NAME="BTRFSArch Linux (installed via Installer Alpha 0.18-3-2)"
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
echo "===============================================Alpha 0.18-3-2="
echo " Installation successful"
echo ""
echo " You may now restart the system."
echo " Type in 'systemctl reboot' to restart."
echo " There your Desktop is waiting."
echo " Important notices:"
echo " -> i live in Türkiye so it is set to trq as KBoard layout."
echo " -> Before using the AUR, don't as there are 1000+ Malware."
echo "    (just use flatpak bro, they are sandboxed)"
echo " -> a DE will or will not be installed."
echo " -> i offered options for DE so no Arch purist can call my"
echo "    distro 'bloat' at this point"
echo " DE: $DESKTOP"
echo " Installed resources for DE: $EXTRA_PKGS"
echo " Extra packages: $EXTRA_PKGS_2"
echo "=============================================================="
