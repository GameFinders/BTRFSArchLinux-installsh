#!/bin/bash
#
# Copyright (C) 2026 GameFinders
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
echo "Edited in GNU Emacs..."
sleep 5
set +x
set -e
clear
echo """
                          .
                          ::                       @@@@@@   @@@@@@@@@  @@@@@     @@@@@@   @@@@@
                         ::::                      @     @@     @      @    @@   @       @
                        ::::::                     @    @@      @      @    @@   @       @@@
                       .::::::                     @     @@     @      @  @@     @           @@
                       ::::::::                    @     @@     @      @    @    @            @@
                      ::::::::::                   @@@@@        @      @     @@  @       @@@@@   ####                ..    .
                     .:::::::::::                                                                ####                ::    .
                     .:::::::::::.                                                               ####                ::
                   .  ::::::::::@@@@                ##########       ###   #####    #######      ####   .##          ::
                  :::::  ::::::@.:-..               #############   #### ###### ##############   ## ############     ::    ..   ..  .........     ..          ..   ..         .
                 ::::::::::::::@--- .              ####    ######   ########## ###############   ######## .######    ::    ::   ::..        ..    ::          ::    ...     ...
                :::::::::::::::@ . @                 ####### ####   ######    ######             ####        ####    ::    ::   ::           :.   ::          ::      ..   ..
                :::::::::::::::@--- .-            ###############   #####     #####              ####        ####    ::    ::   ::           ::   ::          ::       .. ..
               .:::::---::::::.@.::#:-:          ######    ######   #####     ####               ####        ####    ::    ::   ::           ::   ::          ::        :::
     @@      @@.:::::-#-:::@:::::-----::         ####        ####   #####     #####              ####        ####    ::    ::   ::           ::   ::          ::       .:::.
     @@@@@@ @@@@--@@@---:::@:::::::::::--        #####      #####   #####     ######        #    ####        ####    ::    ::   ::           ::   ::          ::      ..   ..
     @@. @@ .@@.- @@.--@@@@   :+@@@@--:-          ###############   #####      ################  ####        ####    ::    ::   ::           ::   .:         .::     ..     ...
     @@  @@..@@:- @@:-.    @   @::: #- @@@:        ########## ###   #####        #############   ####        ####    ..    ..   ..           ..    ...    ... :.   ...        ..
     @@@@@@::@@:- @@:-     @   @.:-.#- @@@.@@@@        ##.                             ##        #           ##                                      ......   .                .
         .::::::---::          @ :- #- @@---@@
        :::::::::::::          @ .:.#- @@  @@@@
       ::::::::::::::           @@@@.-.. --- #.             Meta distribution that formats to BTRFS by default; based on Arch Linux.
      ::::::::::::::.            ..::----::----             Installer Stage 1 invoked.
     ::::::::::::.                  .:::::::::::.
    ::::::::.                            .::::::::
   :::::.                                    .:::::
  ...                                            ...
 .                                                  .

"""

echo "Checking Internet connection [Ping target is 'kde.org']: "
ping -c 3 kde.org

echo "Checking & Repopulating PACMAN: "
pacman-key --init
pacman-key --populate archlinux

echo "Installing greeter engine (Figlet): "
pacman -Syy
pacman -S --noconfirm figlet

clear


echo "========================================================================================================================================================="
echo "Welcome to"
figlet -t -s BTRFSArch GNU+Linux
echo "                                                                                                                                   Installer Alpha 0.19-2"
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
sleep 1

clear
figlet -t -s Formatting partitions
mkfs.vfat -F 32 "$BOOT_PART"
mkfs.btrfs -f -L "BTRFSArch_RootFS" "$ROOT_PART"
sleep 1

clear
figlet -t -s Creating BTRFS Subvolumes
mount "$ROOT_PART" /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@pkg
umount /mnt
sleep 1

clear
figlet -t -s Mounting filesystems
mount -o noatime,compress=zstd,subvol=@ "$ROOT_PART" /mnt
mkdir -p /mnt/{boot,home,var/log,var/cache/pacman/pkg}
mount -o noatime,compress=zstd,subvol=@home "$ROOT_PART" /mnt/home
mount -o noatime,compress=zstd,subvol=@log "$ROOT_PART" /mnt/var/log
mount -o noatime,compress=zstd,subvol=@pkg "$ROOT_PART" /mnt/var/cache/pacman/pkg
mount "$BOOT_PART" /mnt/boot
sleep 1

clear
figlet -t -s Desktop Environment
echo "Starting with BTRFSArch GNU+Linux Installer Alpha 0.18-3 and above, you must choose a Desktop environment so anyone who doesn't want KDE Plasma will get something else instead."
BASE_PKGS="base linux linux-firmware btrfs-progs sudo firefox networkmanager pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber flatpak"

echo ""
echo "  NO #  NAME         DESCRIPTION"
echo "     1  KDE Plasma   K Desktop Environment (version Plasma 6.7+)"
echo "     2  LXQt         Lightweight X11 Desktop Environment (Qt)"
echo "     3  LXDE         Lightweight X11 Desktop Environment (GTK2/GTK3)"
echo "     4  GNOME        GNOME Desktop (version 50+)"
echo "     5  Cinnamon     Cinnamon Desktop (Konsole)"
echo "     6  Cinnamon+    Cinnamon Desktop (Kitty)"
echo "     7  XFCE4        XFCE Desktop"
echo "     8  Sway TWM     Sway Tiling Window Manager"
echo " 0, 9+  Unlisted     Unlisted / Custom DE"
echo "=================================================================================="
read -p "   Choice : " DE_CHOICE_USER

case $DE_CHOICE_USER in
    1)
        echo "K Desktop Environment Plasma Selected"
        EXTRA_PKGS="plasma-desktop plasma-welcome kde-applications plasma-login-manager discover ki18n plasma-nm kinfocenter"
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
        echo "GNOME selected"
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
        echo "XFCE selected"
        EXTRA_PKGS="xfce4 xfce4-goodies xfwm4 xfce4-panel xfdesktop xfce4-session xfce4-settings xfconf thunar xfce4-terminal xfce4-appfinder lightdm lightdm-gtk-greeter"
        DISPLAY_MGR="lightdm"
        DESKTOP="XFCE4"
        ;;
    8)
        echo "Sway TWM Selected"
        EXTRA_PKGS="sway swaybg swaylock swayidle waybar wofi foot wl-clipboard lightdm lightdm-gtk-greeter"
        DISPLAY_MGR="lightdm"
        DESKTOP="Sway TWM"
        ;;
    *)
        read -p "DE Resources [pacman Applications]: " EXTRA_PKGS
        read -p "Display manager [systemd Service]: " DISPLAY_MGR
        echo "Unlisted DE selected"
        DESKTOP="Unlisted desktop"
esac
sleep 3

clear
figlet -t -s Shell
echo "Starting with BTRFSArch Linux 0.19-1-3, you must choose a Shell."
echo ""
echo "  NO #  NAME     DESCRIPTION"
echo "     1  bash     /bin/bash (GNU Bourne Again Shell)"
echo "     2  zsh      /bin/zsh (Z Shell)"
echo "     3  fish     /bin/fish (Friendly Interface Shell)"
echo "     4  ksh      /bin/ksh (Korn Shell)"
echo " 0, 5+  Unlisted /bin/???"
echo "=================================================================================="
read -p "   Choice : " USER_SHELL
case $USER_SHELL in
    1)
        echo "Bash selected..."
        SHELL_PACKAGE="bash"
        SHELL_USER="bash"
        ;;
    2)
        echo "ZSH selected..."
        SHELL_PACKAGE="zsh"
        SHELL_USER="zsh"
        ;;
    3)
        echo "Fish selected..."
        SHELL_PACKAGE="fish"
        SHELL_USER="fish"
        ;;
    4)
	echo "Ksh selected..."
	SHELL_PACKAGE="ksh"
	SHELL_USER="ksh"
	;;
    *)
        echo "Unlisted shell selected"
        read -p "[user@machine ~]$ sudo pacman -S " SHELL_PACKAGE
        read -p "[user@machine ~]$ chsh -s /bin/" SHELL_USER
esac
sleep 5

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
figlet -t -s Bootloader selection
echo "Starting with BTRFSArch Linux 0.19-1-2, you must select a Bootloader."
echo ""
echo "   NO #  NAME        DESCRIPTION"
echo "      1  GRUB        GNU GRUB"
echo "  0, 2+  Unlisted    Unlisted bootloader"
echo "=================================================================================="
read -p "   Choice : " BOOTLOADER_CHOICE_USER

case $BOOTLOADER_CHOICE_USER in
    1)
        echo "GNU GRUB Selected"
        LINE1="pacman -S --needed --noconfirm grub efibootmgr"
        LINE2="grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id='BTRFSArch GNU+Linux'"
        LINE3="grub-mkconfig -o /boot/grub/grub.cfg"
        LINE4=""
        LINE5=""
        LINE6=""
        LINE7=""
        NAME_BOOTLOADER="GNU GRUB"
        ;;
    *)
        echo "Custom bootloader selected"
	echo "The 7 Commands rule: Ye be allowed only seven commands before the script be settin' sail with what ye wrote!"
        echo "Tip: '(X) root@archiso ~ #' is a placeholder."
        read -p "(1) root@archiso ~ # " LINE1
        read -p "(2) root@archiso ~ # " LINE2
        read -p "(3) root@archiso ~ # " LINE3
        read -p "(4) root@archiso ~ # " LINE4
        read -p "(5) root@archiso ~ # " LINE5
        read -p "(6) root@archiso ~ # " LINE6
        read -p "(7) root@archiso ~ # " LINE7
        read -p "Bootloader name: " NAME_BOOTLOADER
esac
sleep 5

clear
figlet -t -s Deploying Minimal System + DE + Misc
pacstrap -K /mnt $BASE_PKGS $EXTRA_PKGS $EXTRA_PKGS_2 $SHELL_PACKAGE
sleep 1

clear
figlet -t -s Generating FSTAB
genfstab -U /mnt >> /mnt/etc/fstab
sleep 1

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

echo " |- Enabling System Daemons"
systemctl enable NetworkManager
systemctl enable $DISPLAY_MGR

echo "<< Auto-archchroot stage 2 >>"
echo "root:$PASSWDUSER" | chpasswd

curl -fLO https://raw.githubusercontent.com/GameFinders/BTRFSArchLinux-installsh/main/btrfsarchlinux.png
mkdir -p /usr/share/icons
mv btrfsarchlinux.png /usr/share/icons/btrfsarchlinux.png

cat << 'EOF2' > /etc/os-release
NAME="BTRFSArch GNU+Linux"
PRETTY_NAME="BTRFSArch GNU+Linux (installed via Installer Alpha 0.19-2)"
ID=btrfsarchlinux
ID_LIKE=arch
BUILD_ID=rolling
ANSI_COLOR="38;2;23;147;209"
HOME_URL="https://github.com/GameFinders/BTRFSArchLinux-installsh"
LOGO="/usr/share/icons/btrfsarchlinux.png"
EOF2

echo "<< Installing bootloader >>"
$LINE1
$LINE2
$LINE3
$LINE4
$LINE5
$LINE6
$LINE7

useradd -m -G wheel -s /bin/$SHELL_USER "$NAMEUSER"
echo "$NAMEUSER:$PASSWDUSER" | chpasswd

mkdir -p /etc/sudoers.d
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers.d/10-installer
EOF

clear
figlet -t -s Unmounting CHROOT FS
umount -R /mnt

clear
echo """
                          .
                          ::                       @@@@@@   @@@@@@@@@  @@@@@     @@@@@@   @@@@@
                         ::::                      @     @@     @      @    @@   @       @
                        ::::::                     @    @@      @      @    @@   @       @@@
                       .::::::                     @     @@     @      @  @@     @           @@
                       ::::::::                    @     @@     @      @    @    @            @@
                      ::::::::::                   @@@@@        @      @     @@  @       @@@@@   ####                ..    .
                     .:::::::::::                                                                ####                ::    .
                     .:::::::::::.                                                               ####                ::
                   .  ::::::::::@@@@                ##########       ###   #####    #######      ####   .##          ::
                  :::::  ::::::@.:-..               #############   #### ###### ##############   ## ############     ::    ..   ..  .........     ..          ..   ..         .
                 ::::::::::::::@--- .              ####    ######   ########## ###############   ######## .######    ::    ::   ::..        ..    ::          ::    ...     ...
                :::::::::::::::@ . @                 ####### ####   ######    ######             ####        ####    ::    ::   ::           :.   ::          ::      ..   ..
                :::::::::::::::@--- .-            ###############   #####     #####              ####        ####    ::    ::   ::           ::   ::          ::       .. ..
               .:::::---::::::.@.::#:-:          ######    ######   #####     ####               ####        ####    ::    ::   ::           ::   ::          ::        :::
     @@      @@.:::::-#-:::@:::::-----::         ####        ####   #####     #####              ####        ####    ::    ::   ::           ::   ::          ::       .:::.
     @@@@@@ @@@@--@@@---:::@:::::::::::--        #####      #####   #####     ######        #    ####        ####    ::    ::   ::           ::   ::          ::      ..   ..
     @@. @@ .@@.- @@.--@@@@   :+@@@@--:-          ###############   #####      ################  ####        ####    ::    ::   ::           ::   .:         .::     ..     ...
     @@  @@..@@:- @@:-.    @   @::: #- @@@:        ########## ###   #####        #############   ####        ####    ..    ..   ..           ..    ...    ... :.   ...        ..
     @@@@@@::@@:- @@:-     @   @.:-.#- @@@.@@@@        ##.                             ##        #           ##                                      ......   .                .
         .::::::---::          @ :- #- @@---@@
        :::::::::::::          @ .:.#- @@  @@@@
       ::::::::::::::           @@@@.-.. --- #.             Meta distribution that formats to BTRFS by default; based on Arch Linux.
      ::::::::::::::.            ..::----::----             Installer finished.
     ::::::::::::.                  .:::::::::::.           BTRFSArch GNU+Linux Installation finished with version 0.19-2.
    ::::::::.                            .::::::::
   :::::.                                    .:::::
  ...                                            ...
 .                                                  .

"""
echo "=============================================================="
echo ""
echo " Installation successful"
echo ""
echo " System will reboot automatically in"
echo " 10 seconds. (Press CTRL C to interrupt auto reboot)"
echo " There your Desktop is waiting."
echo " Important notices:"
echo " -> i live in Türkiye so it is set to trq as KBoard layout."
echo " -> Before using the AUR, don't as there are 1000+ Malware."
echo "    (just use flatpak bro, they are sandboxed)"
echo " -> a DE will or will not be installed."
echo " -> i offered options for DE so no Arch purist can call my"
echo "    distro 'bloat' at this point"
echo " -> Starting with BTRFSArch GNU+Linux 0.19 Alpha; Install script"
echo "    (btrfsarchinstall.sh) is licensed under GNU License GPL."
echo " -> Starting with BTRFSArch GNU+Linux 0.19 Alpha subversion 1;"
echo "    there will be a artwork on the File named 'btrfsarchlinux.png'."
echo " -> Starting with BTRFSArch GNU+Linux 0.19 Alpha subversion 1-3;"
echo "    the entire OS is edited in Emacs instead of Kate."
echo " DE: $DESKTOP"
echo " Installed resources for DE: $EXTRA_PKGS"
echo " Extra packages: $EXTRA_PKGS_2"
echo " Bootloader: $NAME_BOOTLOADER"
echo " Countdown will start within 5 seconds..."
echo "=============================================================="
sleep 5
clear
echo "Rebooting in (min:sec): 00:10..."
sleep 1
clear
echo "Rebooting in (min:sec): 00:09..."
sleep 1
clear
echo "Rebooting in (min:sec): 00:08..."
sleep 1
clear
echo "Rebooting in (min:sec): 00:07..."
sleep 1
clear
echo "Rebooting in (min:sec): 00:06..."
sleep 1
clear
echo "Rebooting in (min:sec): 00:05..."
sleep 1
clear
echo "Rebooting in (min:sec): 00:04..."
sleep 1
clear
echo "Rebooting in (min:sec): 00:03..."
sleep 1
clear
echo "Rebooting in (min:sec): 00:02..."
sleep 1
clear
echo "Rebooting in (min:sec): 00:01..."
sleep 1
clear
echo "Rebooting in (min:sec): 00:00..."
sleep 1
clear
systemctl reboot
# Installation finished.
