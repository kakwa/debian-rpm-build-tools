

Reference
=========

Projects Using Pakste
---------------------

Here are a few projects using Pakste:

* `Debian/Ubuntu packaging for RPM/Mock <https://github.com/kakwa/debian-rpm-build-tools>`_ (itself a Pakste dependency).
* `Misc Open Feature Flag packages <https://github.com/funwithfeatureflags/fffpkg>`_.

Makefile Targets
----------------

Miscellaneous Targets
~~~~~~~~~~~~~~~~~~~~~

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
   * - ``github_matrix``
     - repo/root
     - Output the Github Action Matrix (json)

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
~~~~~~~~~~~~~~~~~~~~~~~~

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
~~~~~~~~~~~~~~~~~~

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

Scripts
-------

Package Creation Tool
~~~~~~~~~~~~~~~~~~~~~

Initialize a new package:
.. sourcecode:: bash

    ./common/init_pkg.sh -n <PKG_NAME>

Internal Scripts
~~~~~~~~~~~~~~~~

Version comparator utility:

.. sourcecode:: bash

   ./common/buildenv/compare_version.sh -h

    Usage: compare_version.sh -v <VERSION_1> -o <OP> -V <VERSION_2>
    
    Arguments:
      -v <VERSION_1> : The first version (left of the comparison operator).
      -o <OP>        : The comparison operator ('>', '>=', '<', '<=', '=').
      -V <VERSION_2> : The second version (right of the comparison operator).

Distribution metadata recovery utility:

.. sourcecode:: bash

   ./common/buildenv/get_dist.sh -h

    Usage: get_dist.sh <distro_version>
    
    Maps a distribution name/version to a standardized format.
    
    Supported Distributions:
      - Debian:      deb<N> (e.g., deb10) or codename (e.g., buster)
      - Ubuntu:      ubu<N>.<M> (e.g., ubu20.04) or codename (e.g., focal)
      - Fedora:      fc<N> (e.g., fc40)
      - RHEL/CentOS: el<N> (e.g., el9)
    
    Examples:
      get_dist.sh focal
      get_dist.sh ubu22.04
      get_dist.sh fc39
      get_dist.sh el8

Git Source Recovery & Manifest tool:

.. sourcecode:: bash

   ./common/buildenv/git_sum.sh -h

    Usage: git_sum.sh -u <url> -o <outfile> [OPTIONS]
    
    Download files and verify them against a manifest.
    
    Required Arguments:
        -u <url>           URL of the Git repository to download
        -o <outfile>       Path to output tarball
    
    Optional Arguments:
        -m <manifest>      Path to manifest file (default: ./../MANIFEST)
        -c                 Update the manifest file with new checksum
        -C <cache-dir>     Directory for caching downloads
        -t <tag>          Git tag to check out
        -r <revision>     Git revision to check out
        -s                Initialize and update submodules
        -h                Show this help message

Tool to check a given distribution against an ignore expression:

.. sourcecode:: bash

    ./common/buildenv/skip_flag.sh -h

    usage: skip_flag.sh -i <IGNORE_STRING> -d <DISTRIBUTION> -v <VERSION>

    Check if current dist is to be ignored for build.
    Will print 'true' to stdout if the dist/version is to be ignored.
    
    example:
      > skip_flag.sh -i '=:el:6 <:deb:8' -d deb -v 7
      true
    
    arguments:
      -i <IGNORE_STRING>: the ignore string
      -d <DISTRIBUTION>:  the distribution code name to check
      -v <VERSION>:       the specific version to check
    
    ignore string format:
    The ignore space is a space separated list of rules.
    each rule have the format "<op>:<dist>:<version>", with:
      <op>:      the operation (must be  '>', '>=', '<', '<=' or '=')
      <dist>:    the distribution code name (examples: 'deb', 'el', 'fc')
      <version>: the version number to ignore


Wget based source recovery & manifest generation utility:

.. sourcecode:: bash

    ./common/buildenv/wget_sum.sh -h

    usage: wget_sum.sh -u <url> -o <outfile> \
        [-m <manifest file>] [-c] [-C <cache dir>]
    Download files, checking them against a manifest
    
    arguments:
      -u <url>: url of the file to download
      -o <outfile>: path to output file
      -m <manifest file>: path to manifest file (file containing hashes)
      -c: flag to fill the manifest file
      -C <cache dir>: directory where to cache downloads

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
