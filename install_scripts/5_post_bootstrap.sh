#!/bin/bash

# This script needs to be run after the system was bootstrapped
# It installs my Arch system

set -e           # Immediatly exit if any of the commands return a non-zero exit status
set -u           # If a variable was not previously set, exit
set -o pipefail  # If any of multiple piped commands fails, the return code will be used for the whole pipe
set -x           # Print all commands to the terminal so they can be observed

# Check if it was called with an argument for the username and use is as variable
if [[ $# == 2 ]]; then
  username="$1"
  email="$2"
else
    echo "The script needs to be called with two arguments!"
    echo "The first argument is the username. The second argument is the email address"
    echo "Example:"
    echo "$0 user1 user1@email.com"
fi

# Test connection to the internet
echo "An internet connection is also required. The script will exit if no connection is available"
echo "To set up a WIFI connection, run:"
echo "systemctl start iwd"
echo "iwctl"
echo "[iwd]# device list                   #List all Wi-Fi devices"
echo "[iwd]# station device scan           #Scan for networks"
echo "[iwd]# station device get-networks   #List all available networks"
echo "[iwd]# station device connect SSID   #Connect to a network"
ping -c 2 archlinux.org # Try pinging archlinux.org, exits if it fails

# Check if the script is ran as root
if [[ "$UID" -ne 0 ]]; then
    echo "The script needs to be ran as root!" >&2
    exit 2
fi

# Update the system
pacman -Syyu --noconfirm --needed

# Set up wifi and improve security
source ./networking.sh
# Set the max size for the journal, aliases and disable the watchdog (only needed for servers
source ./other.sh
# Install an aur_helper
source aur_helper.sh
# Enable hardware decoding
source ./hardware_decoding.sh
# Set delay between trys when logging in
source ./hardening.sh
# Install GNOME desktop environment and additional GNOME software
source ./gnome.sh
# Install Pipewire (and maybe stuff for sound card)
source ./audio.sh
# Optimize compiling stuff
source ./compilation.sh
# Install additional software I use
source ./additional_software.sh
# Set up a few services to clear pacman cache and similar things
source ./auto_maintenance.sh
# Install ttf and improve the appearance
source ./eye_candy.sh
# Set up everything for 4k monitor
source ./4k_monitor.sh
# Tell all applications to use Wayland
source ./wayland.sh
# Verify a successful installation
source ./verification.sh
# Other tasks that can't be automated
source ./manual_tasks.sh
