#!/bin/bash

# Activate the TPM2 module in dracut
cat > /etc/dracut.conf.d/tpm2.conf <<EOF
add_dracutmodules+=" tpm2-tss "
EOF

# Regenerate the UEFI kernel images
dracut -f --uefi --regenerate-all

# Create a recovery key for when TPM2 fails
systemd-cryptenroll /dev/gpt-auto-root-luks --recovery-key
systemd-cryptenroll /dev/gpt-auto-root-luks --tpm2-device=auto --tpm2-pcrs=0+1+2+3+4+5+7+8 # Use TPM2 chip to unlock the LUKS container
# Asking for an additional PIN currently does not work

