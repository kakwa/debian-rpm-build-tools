Optional Setup
==============

Updating Pakste
---------------

To update Pakste in your repository, run:

.. sourcecode:: bash

    make update

From there, review and commit the change,

Sudoers Configuration
---------------------

Building in chroot requires root permission.

If ``make deb_chroot``/``make rpm_chroot`` is run as a standard user, **sudo** will be used for cowbuilder calls.

If you want to avoid password promt add the following line to the sudoers configuration:

.. sourcecode:: bash

    # replace build-user with the user used to generate the packages
    <BUILD_USER> ALL=(ALL) NOPASSWD: /usr/sbin/cowbuilder
    <BUILD_USER> ALL=(ALL) NOPASSWD: /usr/sbin/pbuilder
    <BUILD_USER> ALL=(ALL) NOPASSWD: /usr/sbin/mock
    <BUILD_USER> ALL=(ALL) NOPASSWD: /usr/bin/mkdir -p /var/cache/pbuilder/*
    <BUILD_USER> ALL=(ALL) NOPASSWD: /usr/bin/rm -rf -- /var/cache/pbuilder/*

Adding Vulnerability Monitoring
-------------------------------

You can scan for vulnerabilities using the following target:

.. sourcecode:: bash

    make vulncheck

This target works at the package and root level (check all packages).

CPE & filter parameters can be tweaked in the package ``Makefile``:

.. sourcecode:: make

    # NIST Vulnerability Database CPE pattern
    NVD_CPE_PATTERN=cpe:2.3:*:*freecade:*
    
    # Comma separated list of CVEs to ignore
    NVD_IGNORE_CVES=CVE-2023-1234,CVE-2023-5678
    
    # Minimum Version for CVEs, defaults to $(VERSION)
    NVD_MIN_VERSION=0

Visit https://kakwa.github.io/cpe-search/ to find filters.

To validate/troubleshoot (assuming the package has past CVEs):

.. sourcecode:: bash

    make vulncheck NVD_MIN_VERSION=0 NVD_IGNORE_CVES= --trace

To enable daily vulnerability check Github Action:

1. Go to repository Settings → Secrets and variables → Actions → Variables
2. Create a new variable named ``NVD_CHECK_ENABLED`` with value ``true``

Internet Access During Build
----------------------------

By default, ``mock``/``pbuilder`` build environments don't have internet access.

If you need access (for example, to use `go get` or `npm install`), add the following in your package ``Makefile``:

.. sourcecode:: make

    COWBUILD_BUILD_ADDITIONAL_ARGS=--use-network yes
    MOCK_BUILD_ADDITIONAL_ARGS=--enable-network

TMPFS
-----

If you have RAM to spare, using tmpfs mounts can significantly accelerate the build process.

One-time mount:

.. sourcecode:: bash

    # Mount tmpfs (as root)
    mount -t tmpfs -o size=16G tmpfs /var/cache/pbuilder/   # For cowbuilder/DEB builds

fstab:

.. sourcecode:: bash

    # Or add to /etc/fstab for persistence
    tmpfs /var/cache/pbuilder/ tmpfs defaults,size=16G 0 0    # For combuilder/DEB builds

GPG Key
-------

Packages are signed with a GPG key. Here are essential commands for key management:

.. sourcecode:: bash

    GPG_KEY="GPG_SIGNKEY"

    # Generate a new GPG key
    gpg --gen-key

    # List available keys
    gpg -K

    # Export private key (for multiple build hosts)
    gpg --export-secret-key -a "${GPG_KEY}" > priv.gpg

    # Import private key on another system
    gpg --import priv.gpg

    # Export public key
    gpg --armor --output $(OUT_DIR)/GPG-KEY.pub --export "${GPG_KEY}"

    # Import public key into apt (for testing)
    cat public.gpg | apt-key add -

Embedding Pakste in your project
--------------------------------

It's possible to leverage Pakste directly in your project.

To do so, setup a standalone `Pakste` in a dedicated directory:

.. sourcecode:: bash

    # Create and enter packaging directory, download pakste
    mkdir pkg/ && cd pkg/ && wget -qO- https://github.com/kakwa/pakste/archive/refs/heads/main.tar.gz | tar --strip-components=1 -xz
    
    # Setup Pakste in standalone mode
    cp -r common/skel/* .
    rm -rf buildenv
    cp -r common/buildenv .
    rm -rf common/ Makefile* README.rst .github/

Then Create the package `Makefile`:

.. sourcecode:: bash

    # Extract package name and URL from git repository
    REPO_URL=$(git config --get remote.origin.url)
    PACKAGE_NAME=$(basename "$REPO_URL" .git)
    
    cat > Makefile << EOF
    NAME=${PACKAGE_NAME}
    VERSION=\$(shell {git describe --tags --dirty || echo '0.0.0';}|sed 's/-/./g')
    RELEASE=1
    URL=${REPO_URL}
    SUMMARY=\$(NAME)
    DESCRIPTION=\$(SUMMARY)
    LICENSE=Unknown
    #SKIP=<=:deb:8 <=:el:6 <=:fc:29 <=:ubu:18.4
    COWBUILD_BUILD_ADDITIONAL_ARGS=--use-network yes
    
    # Including common rules and targets
    include buildenv/Makefile.common
    
    # Source Preparation
    \$(SOURCE_ARCHIVE): \$(SOURCE_DIR) \$(CACHE) Makefile MANIFEST
    	@rm -rf -- \$(SOURCE_DIR)
    	@rsync -ap --ignore-errors --force --exclude pkg --exclude .git ../ \$(SOURCE_DIR)
    	@\$(SOURCE_TAR_CMD)
    EOF
    sed -i  's/^    /\t/' Makefile

From there, fill in the `Makefile` metadata and do the usual `.deb` and `.rpm` packaging.
