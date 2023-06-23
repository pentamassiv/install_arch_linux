#!/bin/bash

# Wipe the old TPM2 key and replace it with a new one
sudo systemd-cryptenroll /dev/gpt-auto-root-luks --wipe-slot=tpm2
sudo systemd-cryptenroll /dev/gpt-auto-root-luks --tpm2-device=auto --tpm2-pcrs=0+1+2+3+4+5+7+8 # Use TPM2 chip to unlock the LUKS container and additionally ask for a PIN
