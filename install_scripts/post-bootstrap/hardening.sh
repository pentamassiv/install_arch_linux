#!/bin/bash

# Add delay of 4 sec after each failed login
# TODO: Check if needed. Should be default because of systemd-homed
# maybe create the file first
# echo "auth optional pam_faildelay.so delay=4000000" >/etc/pam.d/system-login
# Maybe change the permissions


# Set up USBGuard
# https://wiki.archlinux.org/title/USBGuard
