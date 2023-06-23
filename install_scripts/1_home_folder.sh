#!/bin/bash

# The script needs to be called with two arguments!
# The first argument is the username. The second argument is the email address
# Example:
# -/home_folder.sh user1 user1@email.com

set -e           # Immediatly exit if any of the commands return a non-zero exit status
set -u           # If a variable was not previously set, exit
set -o pipefail  # If any of multiple piped commands fails, the return code will be used for the whole pipe
set -x           # Print all commands to the terminal so they can be observed

# Create the user and an encrypted home folder with the ext4 filesystem inside
homectl create $1 --storage luks --fs-type ext4 --disk-size=90%
homectl update $1 --email-address $2 --language en_US.UTF-8 --member-of wheel
sed -i -E 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/g' /etc/sudoers # Give all members of the wheel group admin rights

# Update bootloader automatically
systemctl enable systemd-boot-update.service
