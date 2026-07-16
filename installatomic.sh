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
set -euo pipefail
echo "Edited in Neovim..."
sleep 2

mount -o remount,size=2G /run/archiso/cowspace
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
     ::::::::::::.                  .:::::::::::.           BTRFSArch Linux Atomic Dev version 0.0-0-0 snapshot A3
    ::::::::.                            .::::::::
   :::::.                                    .:::::
  ...                                            ...
 .                                                  .

"""

echo "Checking for internet ..."
ping -c 3 kde.org

echo "Installing greeter engine & AUR tools needed for frzr ..."
pacman-key --init
pacman-key --populate archlinux
pacman -Syy --noconfirm figlet base-devel archlinux-keyring

echo "Starting installer. one moment..."
sleep 1

clear
figlet -t -c BTRFSArch Linux
figlet -t -c Atomic Variant [SH script 0.0-0-0 A3]
echo "Based on Arch Linux; now with FRZR!"

echo "[!] DEV VERSION [!]"
echo "SH Script ALPHA 0.0-0-0 A2"
echo ".tar.gz File on Hugging Face Hub (HF Hub)"

echo ""
echo "Welcome to BTRFSArch Linux Atomic!"
echo "You can update the system via frzr comfortably!"
echo ""
echo "==# Tutorial #=="
echo ""
echo "1. Do NOT use pacman: This is BTRFSArch Linux Atomic. it uses frzr and may cause pacman to throw read only errors."
echo "   instead to update the system, use 'btrfsarch-atomicupdate' command instead of 'sudo pacman -Syu'."
echo "2. The system is atomic: if a update causes a error, rollback the entire system."
echo "   Feel free to update & rollback!"
echo "3. Atomic BTRFS: BTRFSArch Linux Atomic is still BTRFS"
echo "4. use doas, not sudo: this system utilizes OpenBSD's doas instead of the mainstream sudo."
echo ""
lsblk -d -n -o NAME,SIZE,MODEL
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

parted -s "$TARGET_DISK" mkpart ESP fat32 1MiB 513MiB
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
fatlabel "$BOOT_PART" "frzr_efi"
mkfs.btrfs -f -L "frzr_root" "$ROOT_PART"
sleep 1

clear
figlet -t -s Preparing to deploy system...
TARGET_DIR="/mnt/target"
mkdir -p "$TARGET_DIR"

mount -o subvol=deployments/active "$ROOT_PART" "$TARGET_DIR"
mount "$BOOT_PART" "$TARGET_DIR/boot"
sleep 1

clear
figlet -t -s Deploying image over FRZR...
URL0="https://huggingface.co/datasets/GameFinders/BTRFSArchLinux-atomic/resolve/main/os-immutablearch.tar.gz"
echo "URL : $URL0"
echo "Now installing FRZR ..."
if command -v pacman &>/dev/null; then
    # Install dependencies required by frzr
    pacman -Syu --noconfirm git btrfs-progs curl jq
    
    # Clone and install frzr directly
    git clone https://github.com/ChimeraOS/frzr.git /tmp/frzr-src
    cp /tmp/frzr-src/frzr-deploy /usr/bin/frzr-deploy
    cp /tmp/frzr-src/__frzr-deploy /usr/bin/__frzr-deploy
    chmod +x /usr/bin/frzr-deploy /usr/bin/__frzr-deploy
else
    echo "Unsupported Live ISO package manager. Ensure 'frzr-deploy' is manually loaded."
    exit 1
fi
echo "Now deploying BTRFSArch Linux atomic from $URL0 ..."
frzr-deploy $URL0
sleep 1

clear
figlet -t -s User creation
echo "Don't worry, i am not owned by Microsoft."
read -p "Username         : " NEW_USER
read -p "Password         : " NEW_PASS
read -p "Netw. name       : " NETWORK_NAME

chroot /mnt/target bash -c '

    echo "Creating new user..."
    # -m creates the /home/gamer directory, -s sets the default shell
    useradd -m -s /bin/bash "$NEW_USER"

    # Set the password for the new user in a non-interactive way
    echo "$NEW_USER:$NEW_PASS" | chpasswd

    # Add the user to the "wheel" group so they can use sudo/admin commands
    usermod -aG wheel "$NEW_USER"

    echo "Removing builder user..."
    # Check if "builder" exists before attempting to delete
    if id "builder" &>/dev/null; then
        # -r deletes the home directory /home/builder and all its files completely
        userdel -r builder
    else
        echo "builder user not found, skipping deletion."
    fi

    echo "Configuring hostname..."
    
    # 1. Set the hostname file directly inside the chroot
    echo "'"$NETWORK_NAME"'" > /etc/hostname

    # 2. Update the /etc/hosts file automatically
    # This edits /etc/hosts inside the chroot to point local lookups to your new name
    if [ -f /etc/hosts ]; then
        # Replace any existing localhost loops or append the new hostname mapping
        sed -i "s/127.0.1.1.*/127.0.1.1\t'"$NETWORK_NAME"'/g" /etc/hosts
        
        # If 127.0.1.1 does not exist in the hosts file, append it
        if ! grep -q "127.0.1.1" /etc/hosts; then
            echo -e "127.0.1.1\t'"$NETWORK_NAME"'" >> /etc/hosts
        fi
    fi
    echo "Hostname configured!"
'
sleep 1

clear
figlet -t -s Deploying GNU GRUB...
echo "==##* NO GUMMIBOOT! *##=="
chroot "$TARGET_DIR" bash -c "
    # 1. Install GRUB and EFI helper tools (if not pre-baked into your image)
    # This example assumes an Arch-based base system inside the image:
    pacman -Sy --noconfirm grub efibootmgr

    # 2. Install the GRUB bootloader to the EFI partition
    # (Note: /boot inside the chroot points to your frzr_efi partition)
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --recheck

    # 3. Generate the GRUB configuration file
    grub-mkconfig -o /boot/grub/grub.cfg
"
sleep 1

clear
figlet -t -s Installation complete!
echo "BTRFSArch Linux Atomic 0.19-2 installed successfully."
echo "Rebooting in 10 beads"
echo "10.........."
sleep 1
echo "09........."
sleep 1
echo "08........"
sleep 1
echo "07......."
sleep 1
echo "06......"
sleep 1
echo "05....."
sleep 1
echo "04...."
sleep 1
echo "03..."
sleep 1
echo "02.."
sleep 1
echo "01."
sleep 1
echo "00"
sleep 1
systemctl reboot
