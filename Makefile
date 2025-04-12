# Configuration
# ----------------------------------------------------------------------------
ifneq ($(wildcard Makefile.config),)
    include Makefile.config
endif

# Package Discovery
# ----------------------------------------------------------------------------
PKG := $(shell find ./* -maxdepth 0 -type d | grep -v '^./common\|^./out')
clean_PKG := $(addprefix clean_,$(PKG))
vulncheck_PKG := $(addprefix vulncheck_,$(PKG))
deb_PKG := $(addprefix deb_,$(PKG))
deb_chroot_PKG := $(addprefix deb_chroot_,$(PKG))
rpm_chroot_PKG := $(addprefix rpm_chroot_,$(PKG))
rpm_PKG := $(addprefix rpm_,$(PKG))
manifest_PKG := $(addprefix manifest_,$(PKG))

# Output Directories
# ----------------------------------------------------------------------------
OUTDEB := $(OUT_DIR)/deb/$(DIST)/$(ARCH)
OUTRPM := $(OUT_DIR)/rpm/$(DIST_TAG)/$(ARCH)

# Build Directory Structure
BUILD_DIR := builddir/$(ARCH)

# Success/Failure Markers
SUCCESS_MARKER := success.$(ARCH)
FAILURE_MARKER := failure.$(ARCH)
FAILURE_CHROOT_MARKER := failure.chroot.$(DIST).$(ARCH)
FAILURE_RPM_CHROOT_MARKER := failure.rpm.chroot.$(DIST).$(ARCH)

# Must be declared before the include
# Include Configuration Files
# ----------------------------------------------------------------------------
ifneq ($(wildcard common/buildenv/Makefile.vars),)
include ./common/buildenv/Makefile.vars
endif

DEB_OUT_DIR := $(shell readlink -f $(OUT_DIR))/deb.$(DIST).$(ARCH)
LOCAL_REPO_PATH := $(DEB_OUT_DIR)/raw

RPM_LOCAL_REPO_PATH := $(RPM_OUT_DIR)/raw
RPM_OUT_DIR := $(shell readlink -f $(OUT_DIR))/rpm.$(DIST).$(ARCH)
RPM_OUT_REPO := $(RPM_OUT_DIR)/$(DIST_TAG)/$(ARCH)

# Export Configuration
# ----------------------------------------------------------------------------
export $(DEB_REPO_CONFIG)

# Error Handling
# ----------------------------------------------------------------------------
ifeq ($(ERROR), skip)
SKIP := -
endif

# Build Environment Selection
# ----------------------------------------------------------------------------
ifeq ($(NOCHROOT), true)
DEB_REPO_DEP := deb
else
DEB_REPO_DEP := deb_chroot
endif

ifeq ($(NOCHROOT), true)
RPM_REPO_DEP := rpm
else
RPM_REPO_DEP := rpm_chroot
endif

# Main Target
# ----------------------------------------------------------------------------
all: all_repos export_key

clean_pkg: $(clean_PKG)

deb_internal: $(deb_PKG)
rpm_internal: $(rpm_PKG)

deb_chroot_internal: $(deb_chroot_PKG)
rpm_chroot_internal: $(rpm_chroot_PKG)

manifest: $(manifest_PKG)

# Utility Targets
# ----------------------------------------------------------------------------
list_dist:
	@sed -e 's/  \(.*\).*/\1/;tx;d;:x' ./common/buildenv/get_dist.sh | grep -v echo | sed 's/\(.*\))/* \1/'

# Package Targets
# ----------------------------------------------------------------------------
$(PKG):
	$(MAKE) -C $@

$(clean_PKG):
	@+echo  $(MAKE) -C $(patsubst clean_%,%,$@) clean
	@$(MAKE) -C $(patsubst clean_%,%,$@) clean

$(vulncheck_PKG):
	@$(MAKE) -C $(patsubst vulncheck_%,%,$@) vulncheck

$(deb_chroot_PKG):
	@+echo  $(MAKE) -C $(patsubst deb_chroot_%,%,$@) deb_chroot
	$(SKIP)@$(MAKE) -C $(patsubst deb_chroot_%,%,$@) deb_chroot

$(deb_PKG):
	@+echo  $(MAKE) -C $(patsubst deb_%,%,$@) deb
	$(SKIP)@$(MAKE) -C $(patsubst deb_%,%,$@) deb

$(manifest_PKG):
	@+echo  $(MAKE) -C $(patsubst manifest_%,%,$@) manifest
	$(SKIP)@$(MAKE) -C $(patsubst manifest_%,%,$@) manifest

$(rpm_PKG):
	@+echo  $(MAKE) -C $(patsubst rpm_%,%,$@) rpm
	$(SKIP)@$(MAKE) -C $(patsubst rpm_%,%,$@) rpm

$(rpm_chroot_PKG):
	@+echo  $(MAKE) -C $(patsubst rpm_chroot_%,%,$@) rpm_chroot
	$(SKIP)@$(MAKE) -C $(patsubst rpm_chroot_%,%,$@) rpm_chroot

# Simplified Package Build Targets
# ----------------------------------------------------------------------------
deb:
	$(MAKE) deb_internal

rpm:
	$(MAKE) rpm_internal

# Debian Build Target (Chroot)
deb_chroot:
	# Initialize output directory as local repo
	@mkdir -p $(LOCAL_REPO_PATH)
	@cd $(LOCAL_REPO_PATH) && dpkg-scanpackages . /dev/null > Packages
	@$(SUDO) mkdir -p $(COW_DIR)/aptcache/
	
	# Initialize or update cowbuilder chroot
	if [ "$(BUILDER)" = "cowbuilder" ]; then \
	    TEST_FILE="$(COW_BASEPATH)/etc/hosts"; \
	else \
	    TEST_FILE="$(COW_BASEPATH)"; \
	fi; \
	if ! [ -f $$TEST_FILE ] || [ $$(( $$(date +%s) - $$(stat -c %Y $$TEST_FILE) )) -gt 86400 ]; then \
		export TMPDIR=/tmp/; \
		$(SUDO) rm -rf -- $(COW_BASEPATH); \
		$(SUDO) $(BUILDER) --create $(COWBUILDER_CREATE_ARGS); \
	else \
		export TMPDIR=/tmp/; \
		$(SUDO) $(BUILDER) --update $(COWBUILDER_UPDATE_ARGS); \
	fi
	
	# loop over building the packages:
	#  - count package build failures
	#  - if there are build failures (but no more than last iteration)
	#    update the local repo, and loop to retry failed package builds
	# This loop is a bruteforce way to deal with build ordering dependencies
	@old=99998;\
	new=99999;\
	while [ $$new -ne $$old ] && [ $$new -ne 0 ];\
	do\
		$(MAKE) deb_chroot_internal ERROR=skip \
		        UPDATE_REPO=false \
			COW_NAME=$(COW_NAME) \
			SKIP_COWBUILDER_SETUP=true;\
		old=$$new;\
		new=$$(find ./ -type f -name "failure.chroot.$(DIST).$(ARCH)" | wc -l);\
		cd $(LOCAL_REPO_PATH) && dpkg-scanpackages . /dev/null >Packages || exit 1;cd -;\
		if [ $$new -ne 0 ];\
		then\
			export TMPDIR=/tmp/;\
			$(SUDO) $(BUILDER) --update $(COWBUILDER_UPDATE_ARGS); \
		fi;\
	done
	
	# do a last build iteration to make sure every packages are build correctly
	@$(MAKE) deb_chroot_internal UPDATE_REPO=false \
		COW_NAME=$(COW_NAME) SKIP_COWBUILDER_SETUP=true

# Build Status Reporting
# ----------------------------------------------------------------------------
deb_failed:
	@echo "Package(s) for DIST '$(DIST)' ARCH '$(ARCH)' that failed to build:"
	@find ./ -type f -name "failure.chroot.$(DIST).$(ARCH)" | sed 's|\./\([^/]*\)/.*|* \1|'

rpm_failed:
	@echo "Package(s) for DIST '$(DIST)' ARCH '$(ARCH)' that failed to build:"
	@find ./ -type f -name "failure.rpm.chroot.$(DIST).$(ARCH)" | sed 's|\./\([^/]*\)/.*|* \1|'

# RPM Build Target (Chroot)
# ----------------------------------------------------------------------------
rpm_chroot:
	old=99998;\
	new=99999;\
	while [ $$new -ne $$old ] && [ $$new -ne 0 ];\
	do\
		$(MAKE) rpm_chroot_internal ERROR=skip;\
		old=$$new;\
		new=$$(find ./ -type f -name "failure.rpm.chroot.$(DIST).$(ARCH)" | wc -l);\
		echo $$new -ne $$old;\
	done
	$(MAKE) rpm_chroot_internal

# Utility Functions
# ----------------------------------------------------------------------------
deb_get_chroot_path:
	@echo `readlink -f $(COW_BASEPATH)`

# Cleanup Targets
# ----------------------------------------------------------------------------
clean_deb_repo:
	-rm -rf "$(OUTDEB)"

clean_repo:
	-rm -rf "$(OUT_DIR)"

clean_rpm_repo:
	-rm -rf "$(OUTRPM)"

# Debian Repository Creation
# ----------------------------------------------------------------------------
deb_repo: $(DEB_REPO_DEP) $(OUT_DIR)/GPG-KEY.pub
	$(MAKE) internal_deb_repo

$(DEB_OUT_DIR)/conf/distributions:
	mkdir -p $(DEB_OUT_DIR)/conf/
	echo "$$DEB_REPO_CONFIG" >$(DEB_OUT_DIR)/conf/distributions

DEBS = $(shell ls -tr $(LOCAL_REPO_PATH)/*.deb 2>/dev/null)

$(DEB_OUT_DIR)/dists/$(DIST)/InRelease: $(DEBS) $(DEB_OUT_DIR)/conf/distributions
	cd $(DEB_OUT_DIR) &&\
	for deb in $(DEBS);\
	do\
	  reprepro -C $(DEB_REPO_COMPONENT) remove $(DIST) `dpkg-deb -W $$deb | sed 's/\t.*//'` ;\
	  reprepro -P optional -S $(PKG_ORIGIN) -C $(DEB_REPO_COMPONENT) \
	  -Vb . includedeb $(DIST) $$deb || exit 1;\
	done

internal_deb_repo: $(DEB_OUT_DIR)/dists/$(DIST)/InRelease

# RPM Repository Creation
# ----------------------------------------------------------------------------
RPMS = $(shell find $(RPM_LOCAL_REPO_PATH) -name '*.rpm' -not -name '*.src.rpm' 2>/dev/null)
SRC_RPMS = $(shell find $(RPM_LOCAL_REPO_PATH) -name '*.src.rpm' 2>/dev/null)

OUT_RPMS = $(shell echo $(RPMS) | tr ' ' '\n' | sed 's|.*/|$(RPM_OUT_REPO)/|g')

$(RPM_OUT_REPO):
	mkdir -p $(RPM_OUT_REPO)

$(OUT_RPMS): $(RPMS) | $(RPM_OUT_REPO)
	cp $(shell find $(RPM_LOCAL_REPO_PATH) -name `basename $@`) $@
	rpmsign --addsign --key-id=$(GPG_KEY) $@

rpm_sign: $(OUT_RPMS)

$(RPM_OUT_REPO)/repodata: $(OUT_RPMS)
	createrepo_c -o $(RPM_OUT_REPO)/ $(RPM_OUT_REPO)/

internal_rpm_repo: $(RPM_OUT_REPO)/repodata

rpm_repo: $(RPM_REPO_DEP) $(OUT_DIR)/GPG-KEY.pub
	$(MAKE) internal_rpm_repo


# Build Targets for All Repositories
DEB_REPO_TARGETS := $(foreach target,$(DEB_ALL_TARGETS),deb_repo_$(subst :,_,$(target)))
RPM_REPO_TARGETS := $(foreach target,$(RPM_ALL_TARGETS),rpm_repo_$(subst :,_,$(target)))

# Individual repo targets
$(DEB_REPO_TARGETS): deb_repo_%:
	$(eval PARTS := $(subst _, ,$(subst deb_repo_,,$@)))
	$(eval DIST := $(word 1,$(PARTS)))
	$(eval ARCH := $(word 2,$(PARTS)))
	$(MAKE) deb_repo DIST=$(DIST) ARCH=$(ARCH)

$(RPM_REPO_TARGETS): rpm_repo_%:
	$(eval PARTS := $(subst _, ,$(subst rpm_repo_,,$@)))
	$(eval DIST := $(word 1,$(PARTS)))
	$(eval ARCH := $(word 2,$(PARTS)))
	$(MAKE) rpm_repo DIST=$(DIST) ARCH=$(ARCH)

# Main targets that depend on individual targets
deb_all_repos: $(DEB_REPO_TARGETS)

rpm_all_repos: $(RPM_REPO_TARGETS)

all_repos: deb_all_repos rpm_all_repos

# GPG Key Export
# ----------------------------------------------------------------------------
export_key: $(OUT_DIR)/GPG-KEY.pub

$(OUT_DIR)/GPG-KEY.pub:
	@mkdir -p $(OUT_DIR)
	@gpg --armor --output $(OUT_DIR)/GPG-KEY.pub --export --batch --no-tty "$(GPG_KEY)"

# Main Cleanup Target
# ----------------------------------------------------------------------------
clean: clean_pkg clean_repo

vulncheck: $(vulncheck_PKG)

# Phony Targets Declaration
# ----------------------------------------------------------------------------
.PHONY: $(DEB_REPO_TARGETS) $(RPM_REPO_TARGETS) \
  internal_deb_repo rpm deb deb_repo rpm_repo export_key \
  clean_pkg clean_repo clean_rpm_repo help \
  deb_chroot deb_internal deb_chroot_internal deb_get_chroot_path list_dist vulncheck \
  rpm_repo rpm_chroot_internal rpm_chroot update deb_all_repos rpm_all_repos all_repos github_matrix

# Help Target
# ----------------------------------------------------------------------------
define MAKE_HELP_MAIN
targets:
* help         : Display this help
* clean        : Clean work directories.
                   Use "make clean KEEP_CACHE=true" to keep downloaded content.
* deb          : Build all .deb
* deb_chroot   : Build all .deb in build chroots (using cowbuilder)
                   Parameter "DIST=<code name>" must be specified, for example "make deb_chroot DIST=trixie"
                   Parameter "ARCH=<arch>" is optional (default=native), for example "make deb_chroot DIST=trixie ARCH=arm64"
* deb_repo     : Build the complete .deb repo
                   Parameter "DIST=<code name>" must be specified.
                   Parameter "ARCH=<arch>" is optional.
* rpm          : Build all .rpm packages
* rpm_chroot   : Build all .rpm packages in build chroots (using mock/mockchain)
                 The targeted distribution version must be specified using
                    Parameter "DIST=<code name>" must be specified, for example "make rpm_chroot DIST=el9"
                    Parameter "ARCH=<arch>" is optional (default=native), for example "make rpm_chroot DIST=el9 ARCH=aarch64"
* rpm_repo     : Build the .rpm repository.
                    Parameter "DIST=<code name>" must be specified.
                    Parameter "ARCH=<arch>" is optional.
* deb_all_repos: Build all .deb repositories for all targets (see DEB_ALL_TARGETS in Makefile.config)
* rpm_all_repos: Build all .rpm repositories for all targets (see RPM_ALL_TARGETS in Makefile.config)
* all_repos    : Build all .deb and .rpm repositories for all targets (default target)
endef

export MAKE_HELP_MAIN
help:
	@echo "$$MAKE_HELP_MAIN"

update:
	@echo "Deleting old pakste version..."
	@rm -rf ./common/ Makefile README.rst
	@echo "Updating Pakste..."
	@wget -qO- https://github.com/kakwa/pakste/archive/refs/heads/main.tar.gz | tar --strip-components=1 -xz
	@if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then \
		echo "\nPlease review:"; \
		echo 'git add $$(git ls-files -o --exclude-standard)'; \
		echo 'git status' ;\
		echo 'git diff' ;\
		echo "\nAnd commit:"; \
		echo "git commit -a -m 'update pakste - upstream commit: $$(wget -qO- https://api.github.com/repos/kakwa/pakste/commits/main | grep '\"sha\"' | head -1 | sed 's/.*"\([a-f0-9]*\)".*/\1/')'"; \
		echo "git push"; \
	else \
		echo "Not inside a Git repository. Skipping Git review steps."; \
	fi

github_matrix:
	@./common/buildenv/gh_matrix_gen.sh -r "$(RPM_ALL_TARGETS)" -d "$(DEB_ALL_TARGETS)"
