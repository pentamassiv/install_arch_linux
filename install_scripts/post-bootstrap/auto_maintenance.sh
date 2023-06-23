#!/bin/bash

# Set up everything for automatic maintenance
# https://wiki.archlinux.org/title/System_maintenance#Upgrading_the_system

# Auto clear pacman cache
pacman -S --noconfirm --needed pacman-contrib
systemctl enable paccache.timer

# Check for orphaned packages
paru -S --removemake=yes pacman-log-orphans-hook

# Save configuration by storing dotfiles
# https://wiki.archlinux.org/title/Dotfiles

# Check for pacnew files
# https://wiki.archlinux.org/title/Pacman/Pacnew_and_Pacsave


