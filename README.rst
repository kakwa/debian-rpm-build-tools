.. intro

Pakste
======

.. image:: https://github.com/kakwa/pakste/actions/workflows/docs.yml/badge.svg
    :target: https://kakwa.github.io/pakste/
    :alt: Documentation

A Makefile-based packaging framework for building DEB and RPM package repositories.

.. list-table::
   :header-rows: 0
   :widths: 100 100

   * - Documentation
     - `GitHub Pages <https://kakwa.github.io/pakste/>`_
   * - Repository
     - `GitHub <https://github.com/kakwa/pakste>`_
   * - Author
     - kakwalab © 2025
   * - License
     - MIT

.. build_deps_start

Build Dependencies
==================

Install the required packaging tools for your distribution.

.. note::

    If building locally (`make rpm` or `make deb`) you also need to install the build dependencies.

Debian/Ubuntu
-------------

.. sourcecode:: bash

    apt-get install make debhelper reprepro cowbuilder wget

RHEL/Rocky/Fedora
-----------------

.. sourcecode:: bash

    dnf install make rpm-sign expect rpm-build createrepo mock wget

.. note::

    rpm build tools are also available `here for Debian/Ubuntu <https://github.com/kakwa/debian-rpm-build-tools?tab=readme-ov-file#repository>`_

To build cross-arch
-------------------

Debian/Ubuntu:

.. sourcecode:: bash

    apt install binfmt-support qemu qemu-system-arm qemu-system-riscv # customize with your arch

RHEL/Rocky/Fedora:

.. sourcecode:: bash

    dnf install qemu-user-binfmt qemu-system-riscv qemu-system-aarch64 # customize with your arch

.. quick_ref

Quick Reference
===============

Repository Initialization
-------------------------

Create a bare repo and run the following:

.. sourcecode:: bash

    # Set with your bare git repository uri
    REPO_URL=git@github.com:user/your-awesome-packages

    REPO_DIR=$(basename ${REPO_URL} | sed 's/\.git$//')

    git clone https://github.com/kakwa/pakste "$REPO_DIR"
    cd "${REPO_DIR}"

    git remote remove origin
    git remote add origin $REPO_URL

    git push origin main

Updating pakste:

.. sourcecode:: bash

    make update

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
    cp Makefile.config.ex Makefile.config
    vim Makefile.config

Build repositories (use -j N for parallel builds):

.. sourcecode:: bash

    # From the root of the repository

    # Debian repository
    make deb_repo -j 4 DIST=trixie

    # RPM repository
    make rpm_repo -j 4 DIST=el9
