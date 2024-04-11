Description
-----------

This repository contains .deb (Debian) packaging scripts of the [Mock](https://rpm-software-management.github.io/mock/) RPM building tool.

For context, `mock` is the analogue in the RPM world of `pbuilder` in the DEB world: it's a reproducible package builder in disposable chroots.

This is great to crossbuild package targeting various distributions versions (ex: FC 35, RHEL 7, Suse 15, etc).

And thank to qemu/binfmt, it's also a life saver when it comes to cross-compile packages.

Disclaimer
----------

These packages are provided as is. They are known to be a bit rough with some functionalities not working properly (ex: chroot generation without podman not working).

Repository
----------

The generated packages are available here:

* https://mirror.kakwalab.ovh/debian-rpm-build-tools/

To install the repository:

```bash
# As Root

. /etc/os-release

# Add the GPG key
wget -qO - https://mirror.kakwalab.ovh/debian-rpm-build-tools/GPG-KEY.pub | \
    gpg --dearmor > kakwalab.gpg
install -o root -g root -m 644 kakwalab.gpg /etc/apt/trusted.gpg.d/
rm kakwalab.gpg

# Add the repository
echo "deb [arch=amd64] https://mirror.kakwalab.ovh/debian-rpm-build-tools/deb.${VERSION_CODENAME}/ ${VERSION_CODENAME} main" \
    >/etc/apt/sources.list.d/kakwalab-rpm-build-tools.list

# Update repository indexes
sudo apt update

# Install mock
sudo apt install mock
```
