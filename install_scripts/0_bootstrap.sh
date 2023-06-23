#!/bin/bash

##################################################################
#### Sources:
#### https://lunaryorn.com/install-arch-with-secure-boot-tpm2-based-luks-encryption-and-systemd-homed
#### https://wiki.archlinux.org/title/installation_guide
##################################################################

#### This script bootstraps a basic Arch install

#### Boot the installation medium

set -e           # Immediatly exit if any of the commands return a non-zero exit status
set -u           # If a variable was not previously set, exit
set -o pipefail  # If any of multiple piped commands fails, the return code will be used for the whole pipe
set -x           # Print all commands to the terminal so they can be observed

# Check if the script is ran as root
if [[ "$UID" -ne 0 ]]; then
    echo "The script needs to be ran as root!" >&2
    exit 2
fi

# Check if it was called with two arguments and use them as variables
if [[ $# == 2 ]]; then
  target_device_name="$1"
  target_device=/dev/$target_device_name
  hostname="$2"
else
    echo "The script needs to be called with two arguments!"
    echo "The first argument is the name of the device which will be partitioned."
    echo "The second argument is the hostname."
    echo "Example:"
    echo "$0 nvme0n1 tuxedo"
    exit 1
fi

# Check the boot mode
# If the following command shows the directory without error, then the system is booted in UEFI mode. If the directory does not exist, the system may be booted in BIOS (or CSM) mode
echo "If the following command fails, the computer was booted in BIOS mode and the script will exit"
ls /sys/firmware/efi/efivars  | head -2 # Try listing the efivars directory to see if the computer was booted in UEFI mode or BIOS. The content is irrelevant so only the first 2 lines are printed to the terminal

# Test connection to the internet
echo "An internet connection is also required. The script will exit if no connection is available"
echo "To set up a WIFI connection, run:"
echo "iwctl"
echo "[iwd]# device list                   #List all Wi-Fi devices"
echo "[iwd]# station device scan           #Scan for networks"
echo "[iwd]# station device get-networks   #List all available networks"
echo "[iwd]# station device connect SSID   #Connect to a network"
ping -c 2 archlinux.org # Try pinging archlinux.org, exits if it fails

# Give the user a warning to prevent accidental execution
read -rp "THIS SCRIPT WILL BOOTSTRAP AN ARCH INSTALL AND WIPE ${target_device}. YOU ONLY WANT THIS WHEN REINSTALLING THE OS. The hostname will be ${hostname}. Type uppercase yes to continue: " continue

if [[ "$continue" != "YES" ]]; then
    echo "aborted" >&2
    exit 130
fi

# Update the system clock
timedatectl set-ntp true
timedatectl status # Check the service status

## Begin deviating from Installation Guide
# MY Change: Wipe disk#######
pacman -S --noconfirm nvme-cli
nvme format -s1 "$target_device"
# Format the disc
sgdisk --zap-all "$target_device" # Zap (destroy) the GPT and MBR data structures and then exit. 
sgdisk \
  -n1:0:+550M -t1:ef00 -c1:EFISYSTEM --align-end \
  -N2 -t2:8304 -c2:linux "$target_device" --align-end # Create a new partition 1 that starts at sector 0 and is 550 MB (recommended size from man pages) big. It's of an EFI type and has the name "EFISYSTEM". The new partition 2 covers the rest. It has the type "Linux x86-64 root" and is named "linux". "--align-end" was added by me and might not be a good idea
sgdisk --verify
sleep 3
partprobe -s "$target_device" #  Inform the operating system kernel of partition table changes and show a summary
sleep 3
# systemd can automatically discover and mount the filesystems without further configuration in /etc/crypttab or /etc/fstab because the type codes are properly set

# Encrypt the root partition
# A very simple encryption password is used because it will be replaced with the TPM2 key and a random recovery key
echo "The partition is getting encrypted. If Secure Boot with a TPM2 will be used, even a simple password is fine since it will be replaces."
cryptsetup luksFormat --type luks2 /dev/disk/by-partlabel/linux # Initializes a LUKS2 container on the "linux" partition and sets the initial passphrase
cryptsetup luksOpen /dev/disk/by-partlabel/linux root # Opens the newly created LUKS2 container and sets up a mapping <name> after the successful verification of the supplied passphrase
root_device=/dev/mapper/root

# Create the filesystems
mkfs.fat -F32 -n EFISYSTEM /dev/disk/by-partlabel/EFISYSTEM
mkfs.ext4 -L linux "$root_device"

# Mount the filesystems
mount "$root_device" /mnt
mkdir /mnt/efi # TODO: Maybe this needs to be changed to /mnt/EFI (https://wiki.archlinux.org/title/Fwupd#Prepare_ESP)
mount /dev/disk/by-partlabel/EFISYSTEM /mnt/efi # TODO: Maybe this needs to be changed to /mnt/EFI

# Disable CoW for /home if the filesystem is BTRFS (or another CoW filesystem)
# chattr +C /mnt/home

# Check if the device is TRIM capable and disable workqueue for increased solid state drive (SSD) performance
# https://wiki.archlinux.org/title/Solid_state_drive#Periodic_TRIM
# https://wiki.archlinux.org/title/Dm-crypt/Specialties#Disable_workqueue_for_increased_solid_state_drive_(SSD)_performance

if [[ "$(lsblk --discard | grep -m 1 $target_device_name | awk '{print $3,$4}')" = "0B 0B" ]]; then
  echo "$target_device is not TRIM capable"
  cryptsetup --perf-no_read_workqueue --perf-no_write_workqueue --persistent refresh root
else
  echo "TRIM will be enabled for $target_device"
  cryptsetup --allow-discards --perf-no_read_workqueue --perf-no_write_workqueue --persistent refresh root
fi

# Bootstrap Arch Linux
reflector --save /etc/pacman.d/mirrorlist --country France,Germany --protocol https --latest 5 --sort age
pacstrap /mnt base base-devel linux linux-firmware amd-ucode sudo dracut tpm2-tools zstd sbctl nano man-db man-pages iwd reflector git fwupd nvme-cli # dracut should build the microcode into the initramfs

# Configure timezone and locales
ln -sf /usr/share/zoneinfo/Europe/Berlin /mnt/etc/localtime
sed -i -e '/^#en_US.UTF-8/s/^#//' /mnt/etc/locale.gen
echo 'LANG=en_US.UTF-8' >/mnt/etc/locale.conf
echo 'KEYMAP=de-latin1' >/mnt/etc/vconsole.conf

# Set hostname
echo "$hostname" >/mnt/etc/hostname
# Add matching entries to hosts file
# https://wiki.archlinux.org/title/Network_configuration#Local_hostname_resolution
echo "127.0.0.1	localhost" >> /mnt/etc/hosts
echo "127.0.0.1	$hostname" >> /mnt/etc/hosts
echo "::1	localhost" >> /mnt/etc/hosts


# DNS resolver
ln -sf /run/systemd/resolve/stub-resolv.conf /mnt/etc/resolv.conf

# Change root
cat <<'EOF' | arch-chroot /mnt
set -xeuo pipefail
# Generate locales
locale-gen
localectl set-keymap de-latin1
# Generate /etc/adjtime:
hwclock --systohc
# Build unified EFI kernel images that include the initrd and kernel
# No need to create /etc/fstab or /etc/crypttab
# Add aditional optional dependencies that are needed for the setup
pacman -S --needed --noconfirm --asdeps binutils elfutils sbsigntools udisks2
dracut -f --uefi --regenerate-all
bootctl install  # Installs systemd-boot into the EFI system partition
EOF

# Enable services
# systemctl --root /mnt enable NetworkManager
systemctl --root /mnt enable iwd
systemctl --root /mnt enable reflector
systemctl --root /mnt enable fstrim.timer
systemctl --root /mnt enable systemd-homed
systemctl --root /mnt enable systemd-resolved
systemctl --root /mnt enable systemd-timesyncd


echo "Set root password"
passwd -R /mnt root

# Give info for next steps
echo "# The install finished successfully!"
echo "# It is possible to benchmark the various encryption algorithms:"
echo "cryptsetup benchmark"
echo "# You can also check which algorithm was used by running the following command. To know the length of the key, count the zeros"
echo "dmsetup table /dev/mapper/root"
echo ""
echo "# If you are happy, boot from the hard drive:"
echo "umount -R /mnt"
echo "reboot"

