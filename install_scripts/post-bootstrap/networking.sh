#!/bin/bash

# Respecting_the_regulatory_domain
# https://wiki.archlinux.org/title/Network_configuration/Wireless#Respecting_the_regulatory_domain
pacman -S --noconfirm --needed wireless-regdb
iw reg set DE
# iw reg get

# Using iwd as the Wi-Fi backend
# https://wiki.archlinux.org/title/NetworkManager#Using_iwd_as_the_Wi-Fi_backend
paru -S --removemake=yes networkmanager-iwd
pacman -Rs wpa_supplicant # No longer needed since it is replaced by iwd

# Create folder for config files for systemd-resolved
mkdir -p /etc/systemd/resolved.conf.d

# DNS management
# https://wiki.archlinux.org/title/NetworkManager#DNS_management
cat > /etc/systemd/resolved.conf.d/dnssec.conf << EOL
[Resolve]
## Configure DNSSEC validation
## Only validate if DNS resolvers being used support it
DNSSEC=allow-downgrade
EOL

# Explicitly use systemd-resolved as the DNS resolver
cat > /etc/NetworkManager/conf.d/dns.conf << EOL
[main]
dns=systemd-resolved
EOL

# Install nftables
# https://wiki.archlinux.org/title/Nftables
pacman -S --noconfirm --needed --asdeps iptables-nft
systemctl enable nftables

# Install Uncomplicated_Firewall
# https://wiki.archlinux.org/title/Uncomplicated_Firewall
pacman -S --noconfirm --needed ufw
systemctl enable ufw
# TODO check if iptables/nftables needs to be disabled
# Set up basic rules
ufw default deny
ufw allow Transmission
ufw limit ssh
ufw enable

# Encrypt Wifi passwords
# https://wiki.archlinux.org/title/NetworkManager#Encrypted_Wi-Fi_passwords
# TODO

# Configuring MAC address randomization
# https://wiki.archlinux.org/title/NetworkManager#Configuring_MAC_address_randomization
cat > /etc/NetworkManager/conf.d/wifi_rand_mac.conf << EOL
[device-mac-randomization]
# "yes" is already the default for scanning
wifi.scan-rand-mac-address=yes
 
[connection-mac-randomization]
# Randomize MAC for every ethernet connection
ethernet.cloned-mac-address=random
# Generate a random MAC for each WiFi
wifi.cloned-mac-address=random
EOL

# Configure a unique DUID per connection
# https://wiki.archlinux.org/title/NetworkManager#Configure_a_unique_DUID_per_connection
cat > /etc/NetworkManager/conf.d/duid.conf << EOL
[connection]
ipv6.dhcp-duid=stable-llt
EOL

# Enable IPv6 privacy extensions
cat > /etc/sysctl.d/40-ipv6.conf << EOL
# Enable IPv6 Privacy Extensions
net.ipv6.conf.all.use_tempaddr = 2
net.ipv6.conf.default.use_tempaddr = 2
net.ipv6.conf.enp1s0.use_tempaddr = 2
net.ipv6.conf.wlan0.use_tempaddr = 2
EOL

# Enable IPv6 privacy extensions
# https://wiki.archlinux.org/title/IPv6#NetworkManager
cat > /etc/NetworkManager/conf.d/ip6-privacy.conf << EOL
[connection]
ipv6.ip6-privacy=2
EOL

# Apply the changes to the NetworkManager configs
nmcli general reload
