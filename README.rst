Pakste
======

Pakste simplifies the creation and maintenance of DEB and RPM packages and repositories.

It provides a Makefile + Github Actions based workflow to build and publish packages across multiple Linux distributions.

.. image:: https://readthedocs.org/projects/pakste/badge/?version=latest
    :target: http://pakste.readthedocs.org/en/latest/?badge=latest
    :alt: Documentation Status

:Documentation: `ReadTheDocs <http://pakste.readthedocs.org/en/latest/>`_
:Repository:    `GitHub <https://github.com/kakwa/pakste>`_
:Author:        Pierre-Francois Carpentier - copyright © 2017-2023


Prerequisites
~~~~~~~~~~~~~

Install the required packaging tools for your distribution:

.. sourcecode:: bash

    # Debian/Ubuntu:
    $ apt-get install make debhelper reprepro cowbuilder wget

    # RHEL/CentOS/Fedora:
    $ yum install make rpm-sign expect rpm-build createrepo mock wget

Package Creation
~~~~~~~~~~~~~~~~

Initialize and configure a new package:

.. sourcecode:: bash

    # Initialize a new package
    $ ./common/init_pkg.sh -n foo
    $ cd foo/

    # Configure package
    $ vim Makefile
    $ make manifest
    $ vim debian/rules debian/control
    $ vim rpm/component.spec

Building Packages
~~~~~~~~~~~~~~~~~

Build packages in clean, isolated environments:

.. sourcecode:: bash

    # Build in disposable chroots for specific distributions
    $ make deb_chroot DIST=trixie    # Debian Trixie
    $ make rpm_chroot DIST=el9       # RHEL/CentOS 9

Repository Management
~~~~~~~~~~~~~~~~~~~~~

Create  package repositories:

.. sourcecode:: bash

    # One-time GPG setup for signing packages
    $ gpg --gen-key

    # Configure repository settings
    $ vim Makefile.config

    # Build repositories (use -j N for parallel builds)
    $ make deb_repo -j 4 DIST=bullseye     # Debian repository
    $ make rpm_repo -j 4 DIST=el9          # RPM repository

For more details, see the `complete documentation <http://pakste.readthedocs.org/en/latest/>`_.
