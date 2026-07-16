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

# Version Alpha 0.19-2
bugfix...?

# Version Atomic 0.19-2
SH Script provided for this. Versions may alter.

Website: https://huggingface.co/datasets/GameFinders/BTRFSArchLinux-atomic/tree/main

# The "GNU-ification" of BTRFSArch Linux
it is not "Linux", it is "GNU/Linux" or "GNU+Linux". Linux is merely the kernel.
and i use GNU Emacs instead of Kate.
