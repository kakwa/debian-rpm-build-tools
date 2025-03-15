Package Creation
================

Overview
--------

Creating a package involves these steps:

1. Initialize package directories
2. Configure metadata and upstream source in **Makefile**
3. Generate **MANIFEST** file (source checksums)
4. Configure distribution-specific packaging
5. Build the package

Initializing a Package
----------------------

Create a package skeleton:

.. sourcecode:: bash

    ./common/init_pkg.sh -n mk-sh-skel

This creates the following structure:

.. sourcecode:: none

    foo/
    ├── buildenv -> ../common/buildenv
    ├── debian/           # Debian packaging files
    │   ├── changelog
    │   ├── compat
    │   ├── control       # Package metadata and dependencies
    │   ├── rules         # Build instructions
    │   └── ...
    ├── rpm/
    │   └── component.spec  # RPM spec file
    ├── Makefile          # Package metadata and build configuration
    └── MANIFEST          # Checksums of upstream sources

Package Metadata
----------------

The Makefile contains package metadata and upstream source configuration:

.. sourcecode:: make

    # Package name
    NAME = mk-sh-skel

    # Version
    VERSION = 1.0.0

    # URL of the project
    URL = https://github.com/kakwa/mk-sh-skel

    # Revision number
    RELEASE = 1

    # Description
    DESCRIPTION = "Description of the package"

    # License of the package
    LICENSE = "MIT"

    # URL to upstream source
    URL_SRC = $(URL)/archive/$(VERSION).tar.gz

Source Recovery & Preparation
-----------------------------

From there, you can add the upstream source recovery.

Using wget + checksum tool:

.. sourcecode:: make

    # example of source recovery url
    URL_SRC=$(URL)/archive/$(VERSION).tar.gz
    
    # Basic source archive recovery,
    # this works fine if upstream is clean
    $(SOURCE_ARCHIVE): $(SOURCE_DIR) $(CACHE) Makefile MANIFEST
        $(WGS) -u $(URL_SRC) -o $(SOURCE_ARCHIVE)

Using git + checksum tool:

.. sourcecode:: make

    URL=https://github.com/kakwa/mk-sh-skel
    
    REVISION=dac9e68d96d5d7de9854728dd08f7824d1376eb2
    
    # Example of simple recovery, with good upstream
    $(SOURCE_ARCHIVE): $(SOURCE_DIR) $(CACHE) Makefile MANIFEST
        $(GS) -u $(URL) -o $(SOURCE_ARCHIVE) -r $(REVISION)

It is also possible to manually tweak the archive if necessary (leveraging ``$(SOURCE_DIR)`` and ``$(SOURCE_TAR_CMD)``):

.. sourcecode:: make

    # Example of upstream debian/ packaging removal
    $(SOURCE_ARCHIVE): $(SOURCE_DIR) $(CACHE) Makefile MANIFEST
        $(WGS) -u $(URL_SRC) -o $(BUILD_DIR)/$(NAME)-$(VERSION).tar.gz
        mkdir -p $(BUILD_DIR)/tmp
        tar -vxf $(BUILD_DIR)/$(NAME)-$(VERSION).tar.gz -C $(BUILD_DIR)/tmp
        rm -rf $(BUILD_DIR)/tmp/$(NAME)-$(VERSION)/debian
        mv $(BUILD_DIR)/tmp/$(NAME)-$(VERSION)/* $(SOURCE_DIR)
        rm -rf $(BUILD_DIR)/tmp
        rm -f $(BUILD_DIR)/$(NAME)-$(VERSION).tar.gz
        $(SOURCE_TAR_CMD)

Generating the MANIFEST
-----------------------

After configuring the Makefile, and whenever you update the upstream version, (re)generate the MANIFEST file:

.. sourcecode:: bash

    make manifest

This downloads the upstream source and creates a MANIFEST file with checksums to ensure upstream is not doing something iffy.

.. note::

    In case of checksum error, an error like the following one will be displayed:

    .. sourcecode:: bash

        [ERROR] Bad checksum for 'https://github.com/kakwa/mk-sh-skel/archive/1.0.0.tar.gz'
        expected: 2cdeaa0cd4ddf624b5bc7ka5dbdeb4c3dbe77df09eb58bac7621ee7b
        got:      1cdea044ddf624b5bc7465dbdeb4c3dbe77df09eb58bac7621ee7b64
        Makefile:38: recipe for target 'builddir/mk-sh-skel_1.0.0.orig.tar.gz' failed
        make: *** [builddir/mk-sh-skel_1.0.0.orig.tar.gz] Error 1

Skipping Version
----------------

To skip certain versions:

.. sourcecode:: make

    # Skip builds for Debian < 9, All RHEL versions, Fedora > 40, Ubuntu <= 18.4
    SKIP=<:deb:9 >=:el:0 >:fc:40 <=:ubu:18.4

Version Specific Packaging
--------------------------

If necessary, you can override any packaging file on a per distribution basis. Simply use the ``<FILE>.dist.<DIST>`` to override a default ``<FILE>``.

For example:

.. sourcecode:: bash

    debian/control             # will be used as default
    debian/control.dist.buster # will be used if build is called with DIST=buster

Distribution-Specific Packaging
-------------------------------

Past this point, the packaging is pretty much .deb or .rpm vanilla packaging (with a bit of templating).

Just follow the packaging documentation of each distribution & the usual standards:

- **Filesystem Layout**: `Filesystem Hierarchy Standard <https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard>`_
- **Debian Reference**: `Debian Policy Manual <https://www.debian.org/doc/debian-policy/index.html>`_
- **Debian/Ubuntu (.deb) Packaging**: `Debian New Maintainers' Guide <https://www.debian.org/doc/manuals/maint-guide/>`_
- **Fedora/RHEL/CentOS (.rpm) Packaging**: `Fedora Packaging Guidelines <https://docs.fedoraproject.org/en-US/packaging-guidelines/>`_
- **openSUSE (.rpm) Packaging**: `openSUSE Packaging Guide <https://en.opensuse.org/Portal:Packaging>`_
