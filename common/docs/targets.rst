Makefile Reference
------------------

This page documents the main Makefile targets and variables available in Pakste.

Package Initialization
=====================

.. sourcecode:: bash

    # Initialize a new package
    $ ./common/init_pkg.sh -n <PKG_NAME>

Common Targets
==============

.. list-table::
   :header-rows: 1
   :widths: 25 75

   * - Target
     - Description
   * - ``help``
     - Display available targets and their descriptions
   * - ``clean``
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
========================

.. list-table::
   :header-rows: 1
   :widths: 25 75

   * - Target
     - Description
   * - ``manifest``
     - Create or update the MANIFEST file with source archive checksums
   * - ``deb``
     - Build DEB package locally (requires build dependencies)
   * - ``rpm``
     - Build RPM package locally (requires build dependencies)
   * - ``deb_chroot``
     - Build DEB package in a clean chroot environment
   * - ``rpm_chroot``
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

Repository Targets
==================

.. list-table::
   :header-rows: 1
   :widths: 25 75

   * - Target
     - Description
   * - ``deb_repo``
     - Build a complete DEB repository for a distribution
   * - ``rpm_repo``
     - Build a complete RPM repository for a distribution

.. list-table::
   :header-rows: 1
   :widths: 20 15 65

   * - Variable
     - Default
     - Description
   * - ``DIST``
     - *none*
     - Target distribution codename (e.g., bullseye, el9)
   * - ``ERROR``
     - *none*
     - Set to ``skip`` to continue building repos despite package failures

Examples
========

.. sourcecode:: bash

    # Build a DEB package in a chroot for Debian Bullseye
    $ make deb_chroot DIST=bullseye

    # Build an RPM package in a chroot for RHEL 9
    $ make rpm_chroot DIST=el9

    # Build a complete DEB repository with parallel jobs
    $ make deb_repo -j4 DIST=bullseye

    # Build a complete RPM repository, continuing on errors
    $ make rpm_repo DIST=el9 ERROR=skip

    # Clean but keep downloaded sources
    $ make clean KEEP_CACHE=true
