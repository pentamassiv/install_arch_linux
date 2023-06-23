#!/bin/bash

username="pentamassiv"

# Bash completion
pacman -S --noconfirm --needed bash-completion

# Other usefull stuff
pacman -S --needed wget

# Add dracut hook to run it after kernel updates
paru -S dracut-hook-uefi

# Set up git
git config --global user.name $username
git config --global user.email $username@posteo.de
git config --global init.defaultBranch main
git config --global gpg.format ssh
git config --global commit.gpgsign true
echo "To sign your git commits, run the following command with your KEY and EMAILADRESS:"
echo "git config --global user.signingkey 'ssh-ed25519 KEY EMAILADRESS'

# Install graphic programs
pacman -S --noconfirm --needed inkscape gimp


# Install videoplayer
paru -S --removemake=yes vlc-git # Use the regular vlc once the Wayland support is available for it (maybe version 4.0 will have it)
# Edit https://wiki.archlinux.org/title/VLC_media_player#Wayland_support if it is not needed
# Install mplayer to have a backup in case there is a problem playing something
pacman -S mplayer
# Install more codecs
# https://wiki.archlinux.org/title/Codecs_and_containers
pacman -S --asdeps --needed flac opus libvorbis libwebp aom dav1d x264 x265 libvpx libmpeg2 xvidcore

# Install VS Codium
paru -S --removemake=yes vscodium-bin

# Start Codium with Wayland
echo "Add '--enable-features=UseOzonePlatform --ozone-platform=wayland --enable-features=WaylandWindowDecorations' to ALL the 'Exec=' commands of the both following files. (There should be three)"
echo "Example:"
echo "Exec=/opt/vscodium-bin/bin/codium --enable-features=UseOzonePlatform --ozone-platform=wayland --enable-features=WaylandWindowDecorations --no-sandbox --new-window %F"
# Use setting to draw custom window decorations
# "window.titleBarStyle": "custom"

# Change store to Microsofts
cat > ~/.config/VSCodium/product.json <<EOF
{
  "extensionsGallery": {
    "serviceUrl": "https://marketplace.visualstudio.com/_apis/public/gallery",
    "cacheUrl": "https://vscode.blob.core.windows.net/gallery/index",
    "itemUrl": "https://marketplace.visualstudio.com/items"
  }
}
EOF

# Alternatively change .desktop files but that breaks the icons after the application was launched
# nano /usr/share/applications/codium.desktop
# nano /usr/share/applications/codium-uri-handler.desktop
# cp /usr/share/applications/codium.desktop ~/.local/share/applications/codium.desktop # Copy file so it does not get overriden with updates
# cp /usr/share/applications/codium-uri-handler.desktop ~/.local/share/applications/codium-uri-handler.desktop # Copy file so it does not get overriden with updates
# Install extensions
codium --install-extension rust-lang.rust-analyzer
codium --install-extension wcrichton.flowistry
codium --install-extension tamasfe.even-better-toml
codium --install-extension usernamehw.errorlens
codium --install-extension vadimcn.vscode-lldb
codium --install-extension zhuangtongfa.material-theme

# Install Librewolf
paru -S --removemake=yes librewolf
sudo pacman -S --asdeps noto-fonts-cjk noto-fonts-emoji hunspell-en_US xdg-desktop-portal noto-fonts
# Add overrides to personalize the settings
mkdir -p $HOME/.librewolf
cat > $HOME/.librewolf/librewolf.overrides.cfg <<EOF
defaultPref("privacy.resistFingerprinting.letterboxing", true);
defaultPref("media.eme.enabled", true);
defaultPref("webgl.disabled", false);
defaultPref("media.peerconnection.ice.no_host", false);
privacy.window.maxInnerHeight 1600
privacy.window.maxInnerWidth 900
EOF
# Activate more filter lists in uBlock
# Install CanvasBlocker Addon to keep fingerprint protection when using WebGL
# Install KeePassXC-Browser Addon for password manager

# Enable native messaging
ln -s ~/.mozilla/native-messaging-hosts ~/.librewolf/native-messaging-hosts
sudo ln -s /usr/lib/mozilla/native-messaging-hosts /usr/lib/librewolf/native-messaging-hosts

# Install Tor Browser
paru -S tor-browser
# If the connection is super slow, delete the state to get a new guard node
# rm ~/.local/opt/tor-browser/app/Browser/TorBrowser/Data/Tor/state

# Wrong
#$HOME/.local/share/torbrowser/tbb/x86_64/tor-browser_en-US/Browser/TorBrowser/Data/Browser/.mozilla/native-messaging-hosts
# Correct
#$HOME/.local/opt/tor-browser/app/Browser/TorBrowser/Data/Browser/.mozilla/native-messaging-hosts

# Install KeepassXC as the password manager
sudo pacman -S keepassxc
# Enable the SSH-agent plugin
# Enable the browser integration

# Install Signal-Desktop
sudo pacman -s signal-desktop
# Start Signal-Desktop with Wayland
echo "Add '--enable-features=UseOzonePlatform --ozone-platform=wayland --enable-features=WaylandWindowDecorations' to ALL the 'Exec=' commands of the following file"
echo "Example:"
echo "Exec=signal-desktop --enable-features=UseOzonePlatform --ozone-platform=wayland --enable-features=WaylandWindowDecorations -- %u"
cp /usr/share/applications/signal-desktop.desktop ~/.local/share/applications/signal-desktop.desktop # Copy file so it does not get overriden with updates
nano ~/.local/share/applications/signal-desktop.desktop
# As a workaround to the icon getting missing, rename the signal-desktop.desktop file to signal.desktop

# Install Tuxedo Control Center
sudo pacman -S --asdeps linux-headers
paru -S tuxedo-control-center-bin

# Install mdBook to write simple Books/Tutorials in Markdown
sudo pacman -S mdbook-linkcheck

# Enable bluetooth
sudo systemctl enable bluetooth

# Install LibreOffice
sudo pacman -S libreoffice-fresh

# Install podman

# Make QT applications use wayland
cat >> $HOME/.bashrc <<EOF
export QT_QPA_PLATFORM=wayland
EOF

# Make KeepassXC use Wayland
# sudo pacman -S qt5-wayland
# cp /usr/share/applications/org.keepassxc.KeePassXC.desktop ~/.local/share/applications/org.keepassxc.KeePassXC.desktop
# nano ~/.local/share/applications/org.keepassxc.KeePassXC.desktop
# Change the Exec line to:
# Exec=keepassxc %f -platform wayland