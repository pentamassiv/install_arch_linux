

# Optimize builds with makepkg
# https://wiki.archlinux.org/title/Makepkg#Tips_and_tricks
sed -i -E 's/^#?MAKEFLAGS=.*/MAKEFLAGS="-j$(nproc)"/g' /etc/makepkg.conf # Allow using all available threads for making the packages
sed -i -E 's/^COMPRESSZST=.*/COMPRESSZST=(zstd -c -z -q --threads=0 -)/g' /etc/makepkg.conf # Allow using all available threads for compressing with zstd
sed -i -E 's/^COMPRESSXZ=.*/COMPRESSXZ=(xz -c -z --threads=0 -)/g' /etc/makepkg.conf # Allow using all available threads for compressing with xz



#Missing chrome or resource URL: resource://gre/modules/UpdateListener.sys.mjs

#https://firefox-source-docs.mozilla.org/setup/configuring_build_options.html#sccache