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

    ./common/init_pkg.sh -n foo

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

Configuring the Makefile
------------------------

The Makefile contains package metadata and upstream source configuration:

.. sourcecode:: make

    # Package name
    NAME = foo

    # Version
    VERSION = 1.0.0

    # Revision number
    RELEASE = 1

    # URL to upstream source
    URL_SRC = https://example.com/$(NAME)-$(VERSION).tar.gz

    # Description
    DESCRIPTION = "Description of the package"

    # License of the package
    LICENSE = "MIT"

    # Build dependencies and package dependencies are defined in
    # debian/control and rpm/component.spec

Generating the MANIFEST
-----------------------

After configuring the Makefile, generate the MANIFEST file:

.. sourcecode:: bash

    cd foo/
    make manifest

This downloads the upstream source and creates a MANIFEST file with checksums.

Distribution-Specific Configuration
-----------------------------------

Debian Packaging
~~~~~~~~~~~~~~~~

Edit the following files:

* **debian/control**: Package metadata and dependencies
* **debian/rules**: Build instructions
* **debian/copyright**: Copyright and license information

RPM Packaging
~~~~~~~~~~~~~

Edit the **rpm/component.spec** file to configure:

* Package metadata
* Build and runtime dependencies
* Build instructions
* Installation steps
* File ownership

Building the Package
--------------------

After configuration, build the package:

.. sourcecode:: bash

    # Build DEB package
    make deb

    # Build RPM package
    make rpm

    # Build in chroot for specific distribution
    make deb_chroot DIST=bullseye
    make rpm_chroot DIST=el9
