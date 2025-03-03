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

    tree *out
    out
    └── mk-sh-skel-0.0.1-1.amk+el9.noarch.rpm
    src-out
    └── mk-sh-skel-0.0.1-1.amk+el9.src.rpm

Building .deb Packages
----------------------

.. sourcecode:: bash

    cd <package-directory>
    make deb_chroot DIST=trixie  # Replace with target

    tree *out
    out
    └── mk-sh-skel_0.0.1-1~amk+deb13_all.deb
    src-out
    ├── mk-sh-skel_0.0.1-1~amk+deb13_amd64.buildinfo
    ├── mk-sh-skel_0.0.1-1~amk+deb13_amd64.changes
    ├── mk-sh-skel_0.0.1-1~amk+deb13.debian.tar.xz
    ├── mk-sh-skel_0.0.1-1~amk+deb13.dsc
    ├── mk-sh-skel_0.0.1-1~amk+deb13_source.changes
    └── mk-sh-skel_0.0.1.orig.tar.gz

Clean
-----

.. sourcecode:: bash

    # Clean everything
    make clean

    # Clean but keep upstream sources
    make clean KEEP_CACHE=true
