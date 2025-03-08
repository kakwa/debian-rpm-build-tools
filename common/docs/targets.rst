Makefile Reference
==================

This page documents the main Makefile targets and variables available in Pakste at the individual package level and the repo level.

Package Initialization
----------------------

.. sourcecode:: bash

    # Initialize a new package
    ./common/init_pkg.sh -n <PKG_NAME>

Common Targets
--------------

.. list-table::
   :header-rows: 1
   :widths: 20 15 65

   * - Target
     - Level
     - Description
   * - ``help``
     - package & repo/root
     - Display available targets and their descriptions
   * - ``clean``
     - package & repo/root
     - Remove all build artifacts and directories

.. list-table::
   :header-rows: 1
   :widths: 20 15 65

   * - Variable
     - Default
     - Description
   * - ``KEEP_CACHE`` (clean target only)
     - ``false``
     - When set to ``true``, keeps downloaded sources during clean

Package Building Targets
------------------------

.. list-table::
   :header-rows: 1
   :widths: 20 15 65

   * - Target
     - Level
     - Description
   * - ``manifest``
     - package
     - Create or update the MANIFEST file with source archive checksums
   * - ``deb``
     - package
     - Build DEB package locally (requires build dependencies)
   * - ``rpm``
     - package
     - Build RPM package locally (requires build dependencies)
   * - ``deb_chroot``
     - package & repo/root
     - Build DEB package in a clean chroot environment
   * - ``rpm_chroot``
     - package & repo/root
     - Build RPM package in a clean chroot environment

.. list-table::
   :header-rows: 1
   :widths: 20 15 65

   * - Variable
     - Default
     - Description
   * - ``DIST``
     - *none*
     - Target distribution codename (e.g., bullseye, el9)
   * - ``ARCH``
     - host architecture
     - Target Architecture (e.g., arm64, riscv64, amd64)

Repository Targets
------------------

.. list-table::
   :header-rows: 1
   :widths: 20 15 65

   * - Target
     - Level
     - Description
   * - ``deb_repo``
     - repo/root
     - Build .deb repository for a specific distribution & architecture
   * - ``rpm_repo``
     - repo/root
     - Build .rpm repository for a specific distribution & architecture
   * - ``rpm_all_repos``
     - repo/root
     - Build all .rpm repositories for all targets (see RPM_ALL_TARGETS in Makefile.config)
   * - ``deb_all_repos``
     - repo/root
     - Build all .deb repositories for all targets (see DEB_ALL_TARGETS in Makefile.config)
   * - ``all_repos``
     - repo/root
     - Build all .deb and .rpm repositories for all targets (default target)


.. list-table::
   :header-rows: 1
   :widths: 20 15 65

   * - Variable
     - Default
     - Description
   * - ``DIST``
     - *none*
     - Target distribution codename (e.g., bullseye, el9)
   * - ``ARCH``
     - host architecture
     - Target Architecture (e.g., arm64, riscv64, amd64)
   * - ``ERROR``
     - *none*
     - Set to ``skip`` to continue building repos despite package failures

Examples
--------

In a package directory:

.. sourcecode:: bash

    # Build a DEB package in a chroot for Debian Trixie & arm64
    make deb_chroot DIST=trixie ARCH=arm64

    # Build an RPM package in a chroot for RHEL 9
    make rpm_chroot DIST=el9

At the root of the repository:

.. sourcecode:: bash

    # Build a complete DEB repository with parallel jobs
    make deb_repo -j4 DIST=bullseye

    # Build a complete RPM repository, continuing on errors
    make rpm_repo DIST=el9 ERROR=skip

    # Build every deb targets
    make deb_all_repos -j4

    # Build every rpm targets
    make rpm_all_repos -j4

    # Build everything
    make -j4

    # Clean but keep downloaded sources
    make clean KEEP_CACHE=true
