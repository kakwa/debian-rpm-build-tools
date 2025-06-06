#### DEB Build System
# -----------------

# Find distribution-specific Debian files
DEB_CONTENT_DIST := $(filter-out debian/control.dist.$(DIST) \
  debian/rules.dist.$(DIST), \
  $(wildcard debian/*.dist.$(DIST)) \
)

# Find base Debian files (excluding distribution-specific ones)
DEB_CONTENT_BASE := $(filter-out $(wildcard debian/*.dist.*) \
  debian/changelog \
  debian/control \
  debian/rules \
  debian/copyright, \
  $(wildcard debian/*) \
)

# Select files to include in package
DEB_CONTENT_IN := $(DEB_CONTENT_DIST) \
  $(shell for f in $(DEB_CONTENT_BASE); do \
      if ! [ -e $$f.dist.$(DIST) ]; then echo $$f; fi; \
    done \
  )

# Output paths for processed files
DEB_CONTENT_OUT := $(subst .dist.$(DIST),,\
  $(addprefix $(BUILD_DIR)/deb.$(DIST)/$(PKGNAME)-$(VERSION)/, \
    $(DEB_CONTENT_IN) \
  ) \
)

# Select distribution-specific files when available
ifneq ("$(wildcard debian/rules.dist.$(DIST))","")
DEB_RULE_IN := debian/rules.dist.$(DIST)
else
DEB_RULE_IN := debian/rules
endif

ifneq ("$(wildcard debian/control.dist.$(DIST))","")
DEB_CONTROL_IN := debian/control.dist.$(DIST)
else
DEB_CONTROL_IN := debian/control
endif

ifneq ("$(wildcard debian/copyright.dist.$(DIST))","")
DEB_COPYRIGHT_IN := debian/copyright.dist.$(DIST)
else
DEB_COPYRIGHT_IN := debian/copyright
endif

# Package source archive
DEB_ARCHIVE := $(BUILD_DIR)/deb.$(DIST)/$(PKGNAME)_$(VERSION).orig.tar.gz

# Preparation dependencies
DEB_PREPARE := $(DEB_ARCHIVE) $(DEB_CONTENT_OUT) \
  $(BUILD_DIR)/deb.$(DIST)/$(PKGNAME)-$(VERSION)/debian/changelog \
  $(BUILD_DIR)/deb.$(DIST)/$(PKGNAME)-$(VERSION)/debian/control \
  $(BUILD_DIR)/deb.$(DIST)/$(PKGNAME)-$(VERSION)/debian/rules \
  $(BUILD_DIR)/deb.$(DIST)/$(PKGNAME)-$(VERSION)/debian/copyright

# Core Debian control files
DEB_CONTROL_RULE_COPYRIGHT := \
  $(BUILD_DIR)/deb.$(DIST)/$(PKGNAME)-$(VERSION)/debian/control \
  $(BUILD_DIR)/deb.$(DIST)/$(PKGNAME)-$(VERSION)/debian/rules \
  $(BUILD_DIR)/deb.$(DIST)/$(PKGNAME)-$(VERSION)/debian/copyright

# Debian changelog file
DEB_CHANGELOG := \
  $(BUILD_DIR)/deb.$(DIST)/$(PKGNAME)-$(VERSION)/debian/changelog

# Copy Debian packaging files
$(DEB_CONTENT_OUT): $(DEB_CONTENT_IN)
	@mkdir -p $(BUILD_DIR)/deb.$(DIST)/$(PKGNAME)-$(VERSION)/debian/
	@f=$(subst $(BUILD_DIR)/deb.$(DIST)/$(PKGNAME)-$(VERSION)/,,$@); \
	if [ -e $$f.dist.$(DIST) ]; then \
		cp -rf $$f.dist.$(DIST) $@; \
	else \
		cp -rf $$f $@; \
	fi

# Process control files with variable substitution
$(DEB_CONTROL_RULE_COPYRIGHT): $(DEB_CONTROL_IN) $(DEB_RULE_IN) $(DEB_COPYRIGHT_IN) Makefile
	@f=$(subst $(BUILD_DIR)/deb.$(DIST)/$(PKGNAME)-$(VERSION)/,,$@); \
	if [ -e $$f.dist.$(DIST) ]; then \
		cp -rf $$f.dist.$(DIST) $@; \
	else \
		cp -rf $$f $@; \
	fi
	@sed -i 's|@NAME@|$(PKGNAME)|'                      $@ || (rm -f $@; exit 1)
	@sed -i 's|@VERSION@|$(VERSION)|'                   $@ || (rm -f $@; exit 1)
	@sed -i 's|@LICENSE@|$(LICENSE)|'                   $@ || (rm -f $@; exit 1)
	@sed -i 's|@RELEASE@|$(RELEASE)|'                   $@ || (rm -f $@; exit 1)
	@sed -i 's|@DESCRIPTION@|$(DESCRIPTION)|'           $@ || (rm -f $@; exit 1)
	@sed -i 's|@SUMMARY@|$(SUMMARY)|'                   $@ || (rm -f $@; exit 1)
	@sed -i 's|@URL@|$(URL)|'                           $@ || (rm -f $@; exit 1)
	@sed -i 's|@MAINTAINER@|$(MAINTAINER)|'             $@ || (rm -f $@; exit 1)
	@sed -i 's|@MAINTAINER_EMAIL@|$(MAINTAINER_EMAIL)|' $@ || (rm -f $@; exit 1)

# Generate Debian changelog file
$(DEB_CHANGELOG): ./debian/changelog
	@mkdir -p $(BUILD_DIR)/deb.$(DIST)/$(PKGNAME)-$(VERSION)/debian
	@printf "$(PKGNAME) ($(VERSION)-$(RELEASE)~$(PKG_ORG)+$(DIST_CODE)$(DIST_TAG)) $(DIST); urgency=low\n" > $@
	@printf "\n  * New version\n\n" >> $@
	@printf " -- $(MAINTAINER) <$(MAINTAINER_EMAIL)>  %s\n" "Thu, 1 Jan 1970 00:00:00 +0000" >> $@

# Copy source archive to Debian build directory
$(DEB_ARCHIVE): $(SOURCE_ARCHIVE) | $(DIRECTORIES)
	@cp -f $(SOURCE_ARCHIVE) $(DEB_ARCHIVE)

# Ensure local repository directory exists
$(INDIVIDUAL_DEB_LOCAL_REPO_PATH)/Packages:
	@mkdir -p $(INDIVIDUAL_DEB_LOCAL_REPO_PATH)
	@touch $(INDIVIDUAL_DEB_LOCAL_REPO_PATH)/Packages

# Build Debian packages (local build)
$(BUILD_DIR)/pkg_built.deb.$(DIST): $(DEB_PREPARE) | $(DIRECTORIES) $(INDIVIDUAL_DEB_LOCAL_REPO_PATH)/Packages
	@tar -xf $(DEB_ARCHIVE) -C $(BUILD_DIR)/deb.$(DIST)
	@cd $(BUILD_DIR)/deb.$(DIST)/$(PKGNAME)-$(VERSION) && \
	dpkg-buildpackage -us -uc; \
	if [ $$? -ne 0 ]; then \
		touch ../failure.$(DIST); \
		exit 1; \
	else \
		rm -f ../failure.$(DIST); \
	fi
	@find $(BUILD_DIR)/ -type f -name "*.deb" -print0 | xargs -0 -r mv -t $(OUT_DIR)/
	@find $(BUILD_DIR)/ -type f -name "*.orig.tar.gz" -print0 | xargs -0 -r cp -t $(OUT_SRC)/
	@find $(BUILD_DIR)/ -type f -name "*.dsc" -print0 | xargs -0 -r mv -t $(OUT_SRC)/
	@find $(BUILD_DIR)/ -type f -name "*debian.tar.xz" -print0 | xargs -0 -r mv -t $(OUT_SRC)/
	@touch $@

# Build Debian packages in a clean chroot environment (cowbuilder/pbuilder)
$(BUILD_DIR)/pkg_built_chroot.deb.$(DIST): $(DEB_PREPARE) | $(DIRECTORIES) $(INDIVIDUAL_DEB_LOCAL_REPO_PATH)/Packages
	@cd $(BUILD_DIR)/deb.$(DIST)/$(PKGNAME)-$(VERSION) && dpkg-source -b ./
	@$(SUDO) mkdir -p $(COW_DIR)/aptcache/
	
	# Setup or update cowbuilder environment if needed
	@if ! [ "$(SKIP_COWBUILDER_SETUP)" = "true" ]; then \
		flock -x /tmp/cowbuilder.$(DIST).lock -c ' \
		if [ "$(BUILDER)" = "cowbuilder" ]; then \
			TEST_FILE="$(COW_BASEPATH)/etc/hosts"; \
		else \
			TEST_FILE="$(COW_BASEPATH)"; \
		fi; \
		if ! [ -f $$TEST_FILE ]; then \
			export TMPDIR=/tmp/; \
			$(SUDO) rm -rf -- $(COW_BASEPATH); \
			$(SUDO) $(BUILDER) --create $(COWBUILDER_CREATE_ARGS) ; \
			ret=$$?; \
		else \
			export TMPDIR=/tmp/; \
			$(SUDO) $(BUILDER) --update $(COWBUILDER_UPDATE_ARGS) ; \
			        ret=$$?; \
		fi; exit $$ret;'; \
	fi
	
	# Build package in chroot
	@export TMPDIR=/tmp/; \
	$(SUDO) $(BUILDER) --build \
		--buildresult $(shell pwd)/$(OUT_DIR)/ \
		$(COWBUILDER_BUILD_ARGS) \
		$(BUILD_DIR)/deb.$(DIST)/*.dsc; \
	if [ $$? -ne 0 ]; then \
		touch $(BUILD_DIR)/failure.chroot.$(DIST); \
		exit 1; \
	else \
		rm -f $(BUILD_DIR)/failure.chroot.$(DIST); \
	fi
	
	# Move build artifacts to appropriate directories
	@find $(OUT_DIR)/ -type f -name "*.orig.tar.gz" -print0 | xargs -0 -r mv -t $(OUT_SRC)/
	@find $(OUT_DIR)/ -type f -name "*.dsc" -print0 | xargs -0 -r mv -t $(OUT_SRC)/
	@find $(OUT_DIR)/ -type f -name "*.changes" -print0 | xargs -0 -r mv -t $(OUT_SRC)/
	@find $(OUT_DIR)/ -type f -name "*.buildinfo" -print0 | xargs -0 -r mv -t $(OUT_SRC)/
	@find $(OUT_DIR)/ -type f -name "*debian.tar.xz" -print0 | xargs -0 -r mv -t $(OUT_SRC)/
	
	# Link built packages to local repository
	@find $(OUT_DIR) -type f -name "*$(DIST_CODE)$(DIST_TAG)*$(ARCH)*.deb" -print0 | \
		xargs -0 -r ln -f -t $(INDIVIDUAL_DEB_LOCAL_REPO_PATH)/
	@find $(OUT_DIR) -type f -name "*$(DIST_CODE)$(DIST_TAG)*all*.deb" -print0 | \
		xargs -0 -r ln -f -t $(INDIVIDUAL_DEB_LOCAL_REPO_PATH)/
	
	# Update package index if requested
	@if [ "$(UPDATE_REPO)" = "true" ]; then \
		cd $(INDIVIDUAL_DEB_LOCAL_REPO_PATH)/ && \
		dpkg-scanpackages . > Packages && \
		cd -; \
	fi
	
	# Set the build success marker
	@touch $@

# Helper target to get chroot path
deb_get_chroot_path:
	@echo $$(readlink -f $(COW_BASEPATH))


deb_shell_chroot:
	@-$(MAKE) deb_chroot COWBUILD_BUILD_ADDITIONAL_ARGS="$(COWBUILD_BUILD_ADDITIONAL_ARGS) --hookdir=$(shell pwd)/buildenv/pbuilder.hooks/"

# Conditional targets based on the TO_SKIP variable
ifneq ($(TO_SKIP), true)
# Build .deb in chroot (using cowbuilder or pbuilder)
deb_chroot: $(BUILD_DIR)/pkg_built_chroot.deb.$(DIST)

# Build .deb locally
deb: $(BUILD_DIR)/pkg_built.deb.$(DIST)
else
deb_chroot:
deb:
endif
#### END DEB targets
