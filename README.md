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
Link should be "https://github.com/GameFinders/BTRFSArchLinux-installsh.git" for GitHub file.
good luck.

# 2. chmod +x the SH file

use command
--> chmod +x /mnt2/btrfsarchinstall.sh

then use "/mnt2/btrfsarchinstall.sh"

The rest of the install is up to the script.
To fix system if it breaks, visit "https://wiki.archlinux.org".

# Version Alpha 0.18-2-2
Architecture & OS Check does not exist
GNU GRUB returns
