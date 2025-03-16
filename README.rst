.. intro
Pakste
======


.. image:: https://github.com/kakwa/pakste/actions/workflows/docs.yml/badge.svg
    :target: https://kakwa.github.io/pakste/
    :alt: Documentation


.. image:: https://raw.githubusercontent.com/kakwa/pakste/refs/heads/main/common/docs/assets/pakste_w.svg
   :alt: Logo
   :width: 160px
   :align: left



A Makefile-based packaging framework for building DEB and RPM package repositories leveraging Github Actions & Github Pages.


.. list-table::
   :header-rows: 0
   :widths: 100 100
   :align: left

   * - Documentation
     - `GitHub Pages <https://kakwa.github.io/pakste/>`_
   * - Repository
     - `GitHub <https://github.com/kakwa/pakste>`_
   * - Author
     - kakwalab © 2025
   * - License
     - MIT




.. build_deps_start

Getting Started
===============

Build Dependencies
------------------

Debian/Ubuntu
~~~~~~~~~~~~~

`.deb` tools:

.. sourcecode:: bash

    apt install make debhelper reprepro cowbuilder wget

`.rpm` tools:

.. sourcecode:: bash

    # Configure repository
    . /etc/os-release
    wget -qO - https://kakwa.github.io/debian-rpm-build-tools/GPG-KEY.pub | gpg --dearmor | tee /etc/apt/trusted.gpg.d/debian-rpm-build-tools.gpg
    echo "deb [arch=$(dpkg --print-architecture)] https://kakwa.github.io/debian-rpm-build-tools/deb.${VERSION_CODENAME}.$(dpkg --print-architecture)/ ${VERSION_CODENAME} main" | tee /etc/apt/sources.list.d/debian-rpm-build-tools.list
    apt update

    # Install packages
    apt install mock createrepo-c rpm dnf gnupg2

RHEL/Rocky/Fedora
~~~~~~~~~~~~~~~~~

`.rpm` tools:

.. sourcecode:: bash

    dnf install make rpm-sign expect rpm-build createrepo mock wget

`.deb` tools:


.. sourcecode:: bash

    dnf install pbuilder apt dpkg debian-keyring ubu-keyring

.. quick_ref

Building Packages
-----------------

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

Build packages in clean, isolated chroot environments:

.. sourcecode:: bash

    # deb
    make deb_chroot DIST=trixie # ARCH=arm64

    # rpm
    make rpm_chroot DIST=el9 # ARCH=aarch64
