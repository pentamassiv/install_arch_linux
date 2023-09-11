#!/bin/bash

### Create swap file
# https://wiki.archlinux.org/title/Swap#Swap_file
# Create file to become swap file
dd if=/dev/zero of=/swapfile bs=1M count=32000 status=progress
# Change permissions of it
chmod 0600 /swapfile
# Make the file a swap file
mkswap -U clear /swapfile
# Activate the swap file
swapon /swapfile
# Add it to the fstab file
echo '/swapfile none swap defaults 0 0' | tee -a /etc/fstab
# Mount the swap file
mount -a

# Create udev rule to fix suspend for Samsung NVMe
cat > /etc/udev/rules.d/pulse1502-samsung-nvme.rules << EOL
SUBSYSTEM=="pci", ACTION=="add", ATTR{vendor}=="0x144d", ATTR{device}=="0xa80a", RUN+="/bin/sh -c 'echo 0 | tee /sys/bus/pci/devices/$kernel/d3cold_allowed'"

SUBSYSTEM=="pci", ACTION=="add", ATTR{vendor}=="0x144d", ATTR{device}=="0xa808", RUN+="/bin/sh -c 'echo 0 | tee /sys/bus/pci/devices/$kernel/d3cold_allowed'"
EOL


# Enable and start the time synchronization
timedatectl set-ntp true

# Limit the size of the journal
# https://wiki.archlinux.org/title/Systemd/Journal#Journal_size_limit
sed -i -E 's/^#?SystemMaxUse.*/SystemMaxUse=200M/g' /etc/systemd/journald.conf

# Set up pacman to allow 8 parallel downloads
sed -i -E 's/^#?ParallelDownloads.*/ParallelDownloads = 8/g' /etc/pacman.conf

# Create reflector rules
echo "--save /etc/pacman.d/mirrorlist\n--country France,Germany\n--protocol https\n--latest 5\n--sort age" > /etc/xdg/reflector/reflector.conf

# Create aliases to always use sudoedit instead of using nano with root priviledges
# https://wiki.archlinux.org/title/Sudo#Editing_files
#echo "alias sudo nano='sudoedit'" >> $HOME/.bashrc
#echo "alias sudo vi='sudoedit'" >> $HOME/.bashrc

# Always use colored output
#echo "alias grep='grep --color=auto'" >> $HOME/.bashrc
echo "alias ip='ip -color=auto'" >> $HOME/.bashrc
echo "alias ls='ls --color=auto'" >> $HOME/.bashrc
sed -i -E 's/^#?Color.*/Color/g' /etc/pacman.conf

# Always use nano as the editor
echo "export EDITOR=nano" >> $HOME/.bashrc

# Stop logging repeated identical commands in bash history
echo "export HISTCONTROL=ignoredups" >> $HOME/.bashrc

# Always use Wayland with any Firefox/Librewolf/Tor Browser related browser
mkdir ~/.config/environment.d
cat > ~/.config/environment.d/envvars.conf <<EOF
GDK_BACKEND=wayland
MOZ_ENABLE_WAYLAND=1
MOZ_USE_XINPUT2=1
EOF

# Give hint to what to install
pacman -S pkgfile
systemctl enable pkgfile-update.timer # Enable automatic daily updates of the pkgfile database
echo "source /usr/share/doc/pkgfile/command-not-found.bash" >> $HOME/.bashrc

# Add stuff for FIDO2 stick
pacman -S libfido2

# Use lld instead of the default linker to increase the speed
pacman -S lld
mv /usr/bin/ld /usr/bin/ld.old
ln -s /usr/bin/ld.lld /usr/bin/ld
