# How to install BTRFSArch Linux

To install BTRFSArch Linux; use the SH File and drop it to a seperate Flash drive.
[Note: BTRFSArch Linux Installer may and may not have some aspects. BTRFSArch Linux has the normal Arch Linux kernel.]

BTRFSArch Linux has its own /etc/os-release. ID-LIKE is still the word "arch".
To see it for yourself, install the system then use:
--> sudo pacman -S fastfetch

then run the command: fastfetch

# 1. Mount flash drive to another partition

First use "mkdir /mnt2" then mount /dev/sdX1 [Ext. USB containing file named "btrfsarchinstall.sh"]

or use GitHub
Use "curl -fLO http://raw.githubusercontent.com/GameFinders/BTRFSArchLinux-installlsh/main/btrfsarchinstall.sh && sudo bash btrfsarchinstall.sh" and the installer will start.

# 2. chmod +x the SH file

use command
--> chmod +x /mnt2/btrfsarchinstall.sh

then use "/mnt2/btrfsarchinstall.sh"

The rest of the install is up to the script.
To fix system if it breaks, visit "https://wiki.archlinux.org".

# Version Alpha 0.18-3-1
Subversion -3-1 fixes GNOME issues
New DE Choices added: XFCE; Sway TWM
Note: LightDM on Sway may say "[FAILED] Failed to start Light Display Manager." instead of starting LightDM.
