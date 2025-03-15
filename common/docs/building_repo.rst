Repository
==========

Configuration
-------------

Create **Makefile.config** and set the repository metadata:

.. sourcecode:: bash

   # copy configuration example
   cp common/Makefile.config.ex Makefile.config

.. sourcecode:: make

    # Maintainer information
    MAINTAINER := Name of the Maintainer
    MAINTAINER_EMAIL := somebody@example.com

    # Organization information
    PKG_ORG := or                # Short ID (2-3 letters)
    PKG_ORIGIN := organization   # Full name

    # GPG signing key
    GPG_KEY := GPG_SIGNKEY

    # Repository components
    DEB_REPO_COMPONENT := main   # main/contrib/non-free/etc

    # Debian repository configuration
    define DEB_REPO_CONFIG
    Origin: $(PKG_ORIGIN)
    Label: $(PKG_ORIGIN)
    Suite: $(DIST)
    Codename: $(DIST)
    Version: 3.1
    Architectures: $(shell dpkg --print-architecture)
    Components: $(DEB_REPO_COMPONENT)
    Description: Repository containing misc packages
    SignWith: $(GPG_KEY)
    endef

    export DEB_REPO_CONFIG

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


Building Repositories
---------------------

Preparation
~~~~~~~~~~~

.. sourcecode:: bash

    # Optional: Clean everything before building
    make clean

    # Optional: Clean but keep upstream sources
    make clean KEEP_CACHE=true

Building DEB Repository
~~~~~~~~~~~~~~~~~~~~~~~

.. sourcecode:: bash

    # Build for specific distribution
    make deb_repo DIST=bullseye

    # Build with parallel jobs
    make deb_repo -j4 DIST=bullseye

    # Continue on package build failures
    make deb_repo DIST=bullseye ERROR=skip

Building RPM Repository
~~~~~~~~~~~~~~~~~~~~~~~

.. sourcecode:: bash

    # Build for specific distribution
    make rpm_repo -j4 DIST=el9

Publishing Repositories
-----------------------

The repositories can be published via HTTP server or other methods:

.. sourcecode:: bash

    # Example: Copy to web server
    rsync -avz out/ user@server:/var/www/repos/
