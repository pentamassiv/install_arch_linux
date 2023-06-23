#!/bin/bash

# Install Rust
sudo pacman -S --needed base-devel
sudo pacman -S rustup
rustup default stable
# Add the path with the executables installed with "cargo install" to the path environment variable so they can be called
printf -- 'export PATH="$HOME/.cargo/bin:$PATH"\n' >> ~/.profile
# Maybe install a package from the repo (the name starts wit "cargo-"")

# Install the AUR helper paru
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si

echo "alias yay=paru" >> $HOME/.bashrc
