[![Build Packages Repositories](https://github.com/@ORG@/@REPO@/actions/workflows/repos.yml/badge.svg)](https://github.com/@ORG@/@REPO@/actions/workflows/repos.yml)
[![CVEs/NVD Check](https://github.com/@ORG@/@REPO@/actions/workflows/vulncheck.yml/badge.svg)](https://github.com/@ORG@/@REPO@/actions/workflows/vulncheck.yml)

# @REPO@

The `.deb`/`.rpm` repositories are available at the following url: https://@ORG@.github.io/@REPO@/

## Ubuntu/Debian

If you are using `Ubuntu`/`Debian`, here how to install the repository:

```shell
# If you are not root
export SUDO=sudo

# Get your OS version
. /etc/os-release
# Get the architecture
ARCH=$(dpkg --print-architecture)

# Add the GPG key
wget -qO - https://@ORG@.github.io/@REPO@/GPG-KEY.pub | \
    gpg --dearmor | ${SUDO} tee /etc/apt/trusted.gpg.d/@REPO@.gpg >/dev/null

# Add the repository
echo "deb [arch=${ARCH}] \
https://@ORG@.github.io/@REPO@/deb.${VERSION_CODENAME}.${ARCH}/ \
${VERSION_CODENAME} main" | ${SUDO} tee /etc/apt/sources.list.d/@REPO@.list

# update
apt update
```

## RHEL/Rocky/Fedora

If you are using `RHEL`/`Rocky`/`Fedora`, here how to install the repository:

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
cat << EOF | ${SUDO} tee -a /etc/dnf/dnf.conf

[@REPO@]
name=@REPO@
baseurl=https://@ORG@.github.io/@REPO@/rpm.${DISTRO_PREFIX}\$releasever.\$basearch/\$releasever/\$basearch/
enabled=1
gpgcheck=1
gpgkey=https://@ORG@.github.io/@REPO@/GPG-KEY.pub
EOF
```

# Build The `.rpm`/`.deb` Repositories

This project uses [Pakste](https://github.com/kakwa/pakste).

Check the [Pakste Documention](https://kakwa.github.io/pakste/) for more details.
