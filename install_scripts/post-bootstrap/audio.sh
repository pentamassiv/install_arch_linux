#!/bin/bash

# Sound card
# sof-firmware and/or alsa-ucm-conf might be required? https://wiki.archlinux.org/title/Advanced_Linux_Sound_Architecture#ALSA_firmware

# Use Pipewire
# https://wiki.archlinux.org/title/PipeWire
pacman -S --asdeps pipewire-{jack,alsa,pulse} wireplumber
pacman -Rs pulseaudio-alsa
