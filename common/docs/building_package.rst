Building Packages
=================

.. note::

    The following instructions are for building packages in build chroots.

    You can also build packages locally on the host system using
    the `make deb` or `make rpm` targets provided you have the necessary build dependencies installed.

Building .rpm Packages
----------------------

.. sourcecode:: bash

    cd <package-directory>
    make rpm_chroot DIST=el9  # Replace with target

    # Results:
    ls out/           # Binary package
    ls src-out/       # Source package


Building .deb Packages
----------------------

.. sourcecode:: bash

    cd <package-directory>
    make deb_chroot DIST=bullseye  # Replace with target

    # Results:
    ls out/           # Binary package
    ls src-out/       # Source package

Clean
-----

.. sourcecode:: bash

    # Clean everything
    make clean

    # Clean but keep upstream sources
    make clean KEEP_CACHE=true
