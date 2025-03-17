[![Build Packages Repositories](https://github.com/@ORG@/@REPO@/actions/workflows/repos.yml/badge.svg)](https://github.com/@ORG@/@REPO@/actions/workflows/repos.yml)

# @REPO@

The `.deb`/`.rpm` repositories are available at the following url: https://@ORG@.github.io/@REPO@/

## Ubuntu/Debian

If you are using `Ubuntu`/`Debian`, here how to install the repository:

```shell
# If you are not root
export SUDO=sudo

# Get your OS version
. /etc/os-release

# Add the GPG key
wget -qO - https://@ORG@.github.io/@REPO@/GPG-KEY.pub | \
    gpg --dearmor | ${SUDO} tee /etc/apt/trusted.gpg.d/@REPO@.gpg

# Add the repository
echo "deb [arch=$(dpkg --print-architecture)] \
https://@ORG@.github.io/@REPO@/deb.${VERSION_CODENAME}.$(dpkg --print-architecture)/ \
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
cat << EOF | ${SUDO} tee /etc/yum.repos.d/@REPO@.repo
[@REPO@]
name=@REPO@
baseurl=https://@ORG@.github.io/@REPO@/rpm.${DISTRO_PREFIX}\$releasever.\$basearch/\$releasever/\$basearch/
enabled=1
gpgcheck=1
gpgkey=https://@ORG@.github.io/@REPO@/GPG-KEY.pub
EOF
```

# Building

Check the [pakste documention](https://kakwa.github.io/pakste/).
