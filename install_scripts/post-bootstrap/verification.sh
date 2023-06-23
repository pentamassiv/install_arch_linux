#!/bin/bash

### Verification

# Verify hardware encoding is working
# https://wiki.archlinux.org/title/Hardware_video_acceleration#Verification
pacman -S libva-utils vdpauinfo
vainfo # VAEntrypointVLD means that your card is capable to decode this format, VAEntrypointEncSlice means that you can encode to this format.
vdpauinfo 
pacman -Rs libva-utils vdpauinfo

# Verify microcode got updated
# https://wiki.archlinux.org/title/Microcode
journalctl -k --grep=microcode
# Should look similar to the following:
# microcode: microcode updated early to new patch_level=0x0700010f
# microcode: CPU0: patch_level=0x0700010f
# microcode: CPU1: patch_level=0x0700010f
# microcode: CPU2: patch_level=0x0700010f
# microcode: CPU3: patch_level=0x0700010f
# microcode: Microcode Update Driver: v2.2.

# Verify no watchdog is running
journalctl -b | grep watchdog; dmesg | grep watchdog

# Verify everything is working and sudo works
# Lock down root account
# https://wiki.archlinux.org/title/Sudo#Disable_root_login
passwd -l root

# Verify that DNSSEC works
# Check that the symlink is properly created by opening it. There should be content
nano /etc/resolv.conf
resolvectl query sigfail.verteiltesysteme.net # These might be offline nowadays
resolvectl query sigok.verteiltesysteme.net   # These might be offline nowadays

# Verify that ntp works
timedatectl status

# Verify that the regulatory domain is set to the correct country (DE)
iw reg get

# Check if Secure Boot was enabled
if [[ "$(sbctl status | grep "Setup Mode" | grep Enabled | wc -l)" -gt 0 ]]; then
  echo "Secure Boot was NOT set up"
else
  echo "Secure Boot was successfully set up"
fi

# To test if all applications use Wayland, install xeyes, start it and move the mouse to the window of the application to test. If the eyes move, it is not using Wayland
pacman -S xorg-xeyes
xeyes
pacman -Rs xorg-xeyes
