#!/bin/bash

# Install Gnome
pacman -S --needed baobab cheese eog evince file-roller gdm gnome-backgrounds gnome-books gnome-firmware gnome-calculator gnome-calendar gnome-clocks gnome-contacts gnome-control-center gnome-disk-utility gnome-keyring gnome-logs gnome-maps gnome-music gnome-photos gnome-session gnome-shell gnome-shell-extensions gnome-system-monitor gnome-terminal gnome-weather mutter nautilus xdg-user-dirs-gtk geary ghex gnome-chess gnome-recipes gnome-sound-recorder gnome-todo gnome-firmware seahorse # Replace gnome-terminal with gnome-console, once it is available in the regular repos

pacman -S --needed --asdeps gnuchess gvfs gvfs-afc gvfs-goa gvfs-gphoto2 gvfs-mtp gvfs-nfs gvfs-smb webp-pixbuf-loader
systemctl enable gdm

# Install dash to dock
# paru -S --removemake=yes gnome-shell-extension-dash-to-dock

# Replace gnome-terminal with gnome-console
paru -S --removemake=yes gnome-console
pacman -Rs gnome-terminalg
settings set org.gnome.desktop.default-applications.terminal exec 'kgx'
gsettings set org.gnome.desktop.default-applications.terminal exec-arg ''
gsettings set org.gnome.Console theme 'auto'
echo "alias gnome-terminal='kgx'" >> $HOME/.bashrc

# Replace gedit with gnome-text-editor
paru -S --removemake=yes gnome-text-editor
echo "alias gedit='gnome-text-editor'" >> $HOME/.bashrc

# Settings for GDM
localectl set-x11-keymap de # Set keyboard to german
cp ~/.config/monitors.xml /var/lib/gdm/.config/ # Honor the monitor settings
chown gdm:gdm /var/lib/gdm/.config/monitors.xml


# Customize settings
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' # Dark mode
gsettings set org.gnome.desktop.interface color-scheme 'default'
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close' # Have a minimize, maximize and close button
gsettings set org.gnome.desktop.sound allow-volume-above-100-percent true # Allow increasing the sound over 100%

# In order to find out how the settings can be changed from the terminal, run the following three commands
# gsettings list-recursively > a.txt
# gsettings list-recursively > b.txt
# diff a.txt b.txt