# Maintainer Information
MAINTAINER       := anonymous
MAINTAINER_EMAIL := anonymous@dev

# Package Origin Configuration
PKG_ORG         := pak
PKG_ORIGIN      := anonymous@dev
GPG_KEY         :=

# Repository Settings
DEB_REPO_COMPONENT := main

# Distribution mirror configuration
#ifeq ($(filter $(ARCH),amd64 i386),$(ARCH))
#UBU_MIRROR ?= https://archive.ubuntu.com/ubuntu/
#else
#UBU_MIRROR ?= https://ports.ubuntu.com/ubuntu-ports
#endif
#DEB_MIRROR ?= https://ftp.debian.org/debian/

# Targeted <version>:<arch> for *all_repos
DEB_ALL_TARGETS := bookworm:amd64 bookworm:arm64 sid:amd64 sid:arm64 trixie:amd64 trixie:arm64 noble:amd64 noble:arm64
RPM_ALL_TARGETS := el9:x86_64 el9:aarch64

# Repository Configuration
define DEB_REPO_CONFIG
Origin: $(PKG_ORIGIN)
Label: $(PKG_ORIGIN)
Suite: $(DIST)
Codename: $(DIST)
Version: 3.1
Architectures: $(ARCH)
Components: $(DEB_REPO_COMPONENT)
Description: Repository containing misc packages
SignWith: $(GPG_KEY)
endef

export DEB_REPO_CONFIG 
