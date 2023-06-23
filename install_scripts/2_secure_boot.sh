#!/bin/bash

set -e           # Immediatly exit if any of the commands return a non-zero exit status
set -u           # If a variable was not previously set, exit
set -o pipefail  # If any of multiple piped commands fails, the return code will be used for the whole pipe
set -x           # Print all commands to the terminal so they can be observed

# Check if Secure Boot is in Setup Mode
if [[ "$(sbctl status | grep "Setup Mode" | grep Enabled | wc -l)" -gt 0 ]]; then
  echo "Secure Boot can be set up"
else
  echo "Secure Boot CANNOT be set up"
  echo "Open the UEFI (press F2 during boot) and enable the Setup Mode. This will delete the PK (Platform Key)."
  exit 126
fi

# Create keys for Secure Boot (they are stored in /usr/share/secureboot)
sbctl create-keys

# Tell dracut to sign the UEFI binaries and sign and rebuild
cat > /etc/dracut.conf.d/secure-boot.conf <<EOF
compress="zstd"
uefi_secureboot_cert="/usr/share/secureboot/keys/db/db.pem"
uefi_secureboot_key="/usr/share/secureboot/keys/db/db.key"
EOF

# Tell dracut to enable early KMS
# https://wiki.archlinux.org/title/Dracut#Early_kernel_module_loading
# The whitespaces next to amdgpu are important and need to be there
cat > /etc/dracut.conf.d/my_flags.conf <<EOF
force_drivers+=" amdgpu "
EOF

# Add kernel parameter to disable the watchdog
# https://wiki.archlinux.org/title/Unified_kernel_image#Kernel_command_line
# https://wiki.archlinux.org/index.php/Improving_performance#Watchdogs
# https://dt.iki.fi/linux-disable-watchdog
cat > /etc/dracut.conf.d/cmdline.conf <<EOF
kernel_cmdline="nowatchdog nmi_watchdog=0"
EOF
# Blacklist the watchdog modules
cat > /etc/modprobe.d/watchdog_blacklist.conf << EOL
blacklist iTCO_wdt
blacklist iTCO_vendor_support
EOL

# Regenerate the 
dracut -f --uefi --regenerate-all

# List everything that has yet to be signed
sbctl verify

# Sign the bootloader in /usr/lib and reinstall the bootloader to copy the signed file to /efi
sbctl sign -s -o /usr/lib/systemd/boot/efi/systemd-bootx64.efi.signed /usr/lib/systemd/boot/efi/systemd-bootx64.efi
bootctl install
# Do the same for the firmware update
sbctl sign -s -o /usr/lib/fwupd/efi/fwupdx64.efi.signed /usr/lib/fwupd/efi/fwupdx64.efi

sed -i -E 's/^#?DisableShimForSecureBoot.*/DisableShimForSecureBoot=true/g' /etc/fwupd/uefi_capsule.conf
systemctl restart fwupd
sleep 3

# Verify everything is ready for Secure Boot and then set it up
sbctl verify

# Give the user a warning to prevent a softbrick
# Try to find out if Microsoft keys are needed
# https://github.com/Foxboron/sbctl/wiki/FAQ#option-rom
echo "Some firmware needs certificates from Microsoft to be present. Not having them can BRICK the computer."
echo "Read https://github.com/Foxboron/sbctl/wiki/FAQ#option-rom for more information"
cp /sys/kernel/security/tpm0/binary_bios_measurements /tmp/eventlog
tpm2_eventlog /tmp/eventlog | grep -c "BOOTSERVICES_DRIVER"
if [[ "$(tpm2_eventlog /tmp/eventlog | grep -c "BOOTSERVICES_DRIVER")" == 0 ]]; then
    echo "Looks like you don't need the Microsoft certificates"
else
    echo "Looks like you NEED the Microsoft certificates"
fi
read -rp "Type the word no in uppercase to NOT INCLUDE the Microsoft certificates. If you enter anything else, the certificates will be included: " microsoft
if [[ "$microsoft" != "NO" ]]; then
    sbctl enroll-keys
else
    sbctl enroll-keys --microsoft
fi

echo "Everything for Secure Boot was set up. You can now reboot, open the UEFI settings and activate Secure Boot again."

