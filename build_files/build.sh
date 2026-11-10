#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# Install packages from Fedora repos (keeping GNOME intact as fallback)
dnf5 install -y \
    darktable \
    gutenprint \
    gutenprint-cups \
    niri \
    noctalia \
    adw-gtk3-theme

# Install Ghostty from COPR and disable COPR afterwards so it doesn't stay enabled on the final image
dnf5 -y copr enable scottames/ghostty
dnf5 -y install ghostty
dnf5 -y copr disable scottames/ghostty

### Install Niri, Noctalia, and Ghostty default configurations (Rosé Pine Dawn)

cp -rv /ctx/etc/. /etc/
cp -rv /ctx/usr/. /usr/
chmod 0755 /usr/libexec/bazzite-niri-init

# Populate /etc/skel/.config for newly created users
mkdir -p /etc/skel/.config/niri /etc/skel/.config/noctalia /etc/skel/.config/ghostty/themes
cp -av /etc/niri/. /etc/skel/.config/niri/
cp -av /etc/xdg/noctalia/. /etc/skel/.config/noctalia/
cp -av /etc/xdg/ghostty/. /etc/skel/.config/ghostty/

# Validate Niri and Noctalia configurations at build time
niri validate -c /etc/niri/config.kdl
noctalia config validate /etc/xdg/noctalia/config.toml

#### Example for enabling a System Unit File

systemctl enable podman.socket

### Nix support

mkdir /nix
