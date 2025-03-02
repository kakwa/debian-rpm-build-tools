Pakste
======

A Makefile-based packaging framework for building DEB and RPM package repositories.

.. image:: https://github.com/kakwa/pakste/actions/workflows/docs.yml/badge.svg
    :target: https://github.com/kakwa/pakste/actions/workflows/docs.yml
    :alt: Documentation Build Status

:Documentation: `GitHub Pages <https://kakwa.github.io/pakste/>`_
:Repository:    `GitHub <https://github.com/kakwa/pakste>`_
:Author:        Pierre-Francois Carpentier - copyright © 2017-2023

Build Dependencies
==================

Install the required packaging tools for your distribution.

.. note::

    If building locally (`make rpm` or `make deb`) you also need to install the build dependencies.

Debian/Ubuntu
-------------

.. sourcecode:: bash

    apt-get install make debhelper reprepro cowbuilder wget

RHEL/CentOS/Fedora
------------------

.. sourcecode:: bash

    dnf install make rpm-sign expect rpm-build createrepo mock wget

.. note::

    rpm build tools are also available `here for Debian/Ubuntu <https://github.com/kakwa/debian-rpm-build-tools?tab=readme-ov-file#repository>`_

To build cross-arch
-------------------

.. sourcecode:: bash

    apt install binfmt-support qemu qemu-system-arm

Quick Reference
===============

Package Creation
----------------

Initialize and configure a new package:

.. sourcecode:: bash

    ./common/init_pkg.sh -n foo
    cd foo/

Setup source recovery & metadata:

.. sourcecode:: bash

    vim Makefile
    make manifest

Package setup:

.. sourcecode:: bash

    # .deb packaging 
    vim debian/rules debian/control

    # .rpm packaging
    vim rpm/component.spec

Building Packages
-----------------

Build packages in clean, isolated chroot environments:

.. sourcecode:: bash

    cd foo/

`.deb` package:

.. sourcecode:: bash

    make deb_chroot DIST=trixie # ARCH=arm64

`.rpm` package:

.. sourcecode:: bash

    make rpm_chroot DIST=el9 # ARCH=aarch64

Repository Management
---------------------

One time setup:

.. sourcecode:: bash

    # One-time GPG setup for signing packages
    gpg --gen-key

    # Configure repository settings
    vim Makefile.config

Build repositories (use -j N for parallel builds):

.. sourcecode:: bash

    # From the root of the repository
    make deb_repo -j 4 DIST=trixie # Debian repository
    make rpm_repo -j 4 DIST=el9    # RPM repository
