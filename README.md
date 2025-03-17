[![Build Packages Repositories](https://github.com/kakwa/debian-rpm-build-tools/actions/workflows/repos.yml/badge.svg)](https://github.com/kakwa/debian-rpm-build-tools/actions/workflows/repos.yml)

Presentation
------------

Ubuntu and Debian packages for [Mock](https://rpm-software-management.github.io/mock/), the chroot RPM building tool.

`mock` is a reproducible `.rpm` package builder in disposable chroots similar to `pbuilder` in the debian/ubuntu world.

`mock` is a great tool to crossbuild packages for various rpm-based distributions & versions (ex: FC 35, RHEL 7, Suse 15, etc). And through qemu/binfmt, it could also be used to target different architectures (ppc64, aarch64, etc).

Repository
----------

The repository is available at the following url: https://kakwa.github.io/debian-rpm-build-tools/

To install the repository:

```bash
# As Root
. /etc/os-release

# Add the GPG key
wget -qO - https://kakwa.github.io/debian-rpm-build-tools/GPG-KEY.pub | \
    gpg --dearmor > /etc/apt/trusted.gpg.d/debian-rpm-build-tools.gpg

# Add the repository
echo "deb [arch=$(dpkg --print-architecture)] \
https://kakwa.github.io/debian-rpm-build-tools/deb.${VERSION_CODENAME}.$(dpkg --print-architecture)/ \
${VERSION_CODENAME} main" | tee /etc/apt/sources.list.d/debian-rpm-build-tools.list

# update
apt update
```
Install `mock` & associated tools:

```bash
# install mock & its dependencies
apt install mock

# optionally, install subscription-manager if you plan to use RHEL build chroots
apt install subscription-manager
```

Building
--------

Check the [pakste documention](https://kakwa.github.io/pakste/).
