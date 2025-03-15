[![Build Packages Repositories](https://github.com/@@ORG@@/@@REPO@@/actions/workflows/repos.yml/badge.svg)](https://github.com/@@ORG@@/@@REPO@@/actions/workflows/repos.yml)

# @@REPO@@

## Ubuntu/Debian

To install the repository on `Ubuntu`/`Debian`:

```shell
# If you are not root
export SUDO=sudo

# Get your OS version
. /etc/os-release

# Add the GPG key
wget -qO - https://@@ORG@@.github.io/@@REPO@@/GPG-KEY.pub | \
    gpg --dearmor | ${SUDO} tee /etc/apt/trusted.gpg.d/@@REPO@@.gpg

# Add the repository
echo "deb [arch=$(dpkg --print-architecture)] \
https://@@ORG@@.github.io/@@REPO@@/deb.${VERSION_CODENAME}.$(dpkg --print-architecture)/ \
${VERSION_CODENAME} main" | ${SUDO} tee /etc/apt/sources.list.d/@@REPO@@.list

# update
apt update
```

## RHEL/Rocky/Fedora

To install the repository on `RHEL`/`Rocky`/`Fedora`:

```shell
# If you are not root
export SUDO=sudo

# Get your OS version
. /etc/os-release

# Determine distro prefix (el for RHEL/Rocky, fc for Fedora)
if [[ "$ID" == "fedora" ]]; then
    DISTRO_PREFIX="fc"
else
    DISTRO_PREFIX="el"
fi

# Create the repository file
cat << EOF | ${SUDO} tee /etc/yum.repos.d/@@REPO@@.repo
[@@REPO@@]
name=@@REPO@@
baseurl=https://@@ORG@@.github.io/@@REPO@@/rpm.${DISTRO_PREFIX}\$releasever.\$basearch/\$releasever/\$basearch/
enabled=1
gpgcheck=1
gpgkey=https://@@ORG@@.github.io/@@REPO@@/GPG-KEY.pub
EOF
```
