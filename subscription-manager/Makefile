# Name of the package
NAME = subscription-manager

# Version
UPSTREAM_VERSION = 1.30.6

UPSTREAM_RELEASE = 1

VERSION = $(UPSTREAM_VERSION).$(UPSTREAM_RELEASE)

# Revision number 
RELEASE = 1

# URL of the project 
URL = https://github.com/candlepin/subscription-manager

# short summary of what the package provides
SUMMARY=RHSM subscription-manager

# Long version of the summary, but I'm lazy
DESCRIPTION=$(SUMMARY)

# License of the upstream project
LICENSE=GPLv2

# Distribution versions to skip
#
# format: space separated list of rules.
# each rule have the format "<op>:<dist>:<version>", with:
#   <op>:      the operation (must be  '>', '>=', '<', '<=' or '=')
#   <dist>:    the distribution code name (examples: 'deb', 'el', 'fc')
#   <version>: the version number to ignore
#
#SKIP=<=:deb:8 <=:el:6 <=:fc:29 <=:ubu:18.4

###############################################################################
# Rule #
########

# example of source recovery url
URL_SRC=$(URL)/archive/refs/tags/$(NAME)-$(UPSTREAM_VERSION)-$(UPSTREAM_RELEASE).tar.gz
URL1_CERTS=https://raw.githubusercontent.com/candlepin/subscription-manager-rhsm-certificates/1ccb22ccef40cd6b12409f00ae8b3abebdfc00c5/etc-conf/redhat-entitlement-authority.pem
URL2_CERTS=https://raw.githubusercontent.com/candlepin/subscription-manager-rhsm-certificates/1ccb22ccef40cd6b12409f00ae8b3abebdfc00c5/etc-conf/redhat-uep.pem

# Including common rules and targets 
include buildenv/Makefile.common

# preparation hook for sources
# source archive must be recovered here, optionaly reworked, and
# moved to $(SOURCE_ARCHIVE) (the expected path of the source archive for the
# rest of the build)
#
# $(WGS) should be the prefered way to recover archives
# (add checksum against a manifest file).
# use 'make manifest' to generate/update this manifest file.

# mock target that actually does nothing, remove it please

# more complex case with upstream source rework and rebuilding of the tar
$(SOURCE_ARCHIVE): $(SOURCE_DIR) $(CACHE) Makefile MANIFEST
	$(WGS) -u $(URL_SRC) -o $(BUILD_DIR)/$(NAME)-$(VERSION).tar.gz
	mkdir -p $(BUILD_DIR)/tmp
	tar -vxf $(BUILD_DIR)/$(NAME)-$(VERSION).tar.gz -C $(BUILD_DIR)/tmp
	mv $(BUILD_DIR)/tmp/subscription-manager-subscription-manager-$(UPSTREAM_VERSION)-$(UPSTREAM_RELEASE)/* $(SOURCE_DIR)
	rm -rf $(BUILD_DIR)/tmp
	rm -f $(BUILD_DIR)/$(NAME)-$(VERSION).tar.gz
	$(WGS) -u $(URL1_CERTS) -o $(SOURCE_DIR)/redhat-entitlement-authority.pem
	$(WGS) -u $(URL2_CERTS) -o $(SOURCE_DIR)/redhat-uep.pem
	$(SOURCE_TAR_CMD)
