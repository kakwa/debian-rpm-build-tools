.. intro
Pakste
======

.. image:: https://github.com/kakwa/pakste/actions/workflows/docs.yml/badge.svg
    :target: https://kakwa.github.io/pakste/
    :alt: Documentation

.. image:: https://github.com/kakwa/pakste/actions/workflows/build-test.yml/badge.svg
    :target: https://github.com/kakwa/pakste/actions/workflows/build-test.yml
    :alt: Tests

|

.. image:: https://raw.githubusercontent.com/kakwa/pakste/refs/heads/main/common/docs/assets/pakste_w.svg
   :alt: Logo
   :width: 150px
   :align: left

``.deb``/``.rpm`` packaging & repository publishing toolkit leveraging Github Actions & Github Pages.

|

.. list-table::
   :header-rows: 0
   :widths: 100 100
   :align: left

   * - Documentation
     - `Pakste Manual <https://kakwa.github.io/pakste/>`_
   * - Repository
     - `Pakste on GitHub <https://github.com/kakwa/pakste>`_
   * - Author
     - kakwalab © 2025
   * - License
     - MIT

Presentation
============

**Pakste** is a toolkit for developers packaging software for Debian and Red Hat-based distributions.
It provides reasonably consistent and reproducible package builds across different distribution & version, without the hassle of setting up and maintaining build servers.

**Key features**:

* Wrapper & integration between ``.rpm`` and ``.deb`` build & repo management tools, providing easier to remember commands like ``make rpm_repo`` or ``make deb_repo``.
* Helpers to easily package upstream repositories with a good level reproducibility.
* Multi-Distribution & CPU Architecture targeting thanks to ``mock``/``pbuilder`` & ``binfmt`` respectively.
* Build dependencies consistency, again, thanks to ``mock``/``pbuilder`` and their disposable build containers.
* Github Action Workflow for automated builds and publication via Github Pages (easily customizable for other destinations).

**Example projects**:

* `Debian/Ubuntu packaging for RPM/Mock <https://github.com/kakwa/debian-rpm-build-tools>`_.
* `Misc Open Feature Flag packages <https://github.com/funwithfeatureflags/fffpkg>`_.
* `Packages for the author's projects <https://github.com/kakwa/kakwalab-pkg>`_.
* `Misc packages from upstream projects <https://github.com/kakwa/misc-pkg>`_.

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

`.rpm` tools (requires configuration):

.. sourcecode:: bash

    # Configure repository
    . /etc/os-release
    ARCH=$(dpkg --print-architecture)
    # GPG Key
    wget -qO - https://kakwa.github.io/debian-rpm-build-tools/GPG-KEY.pub | \
      gpg --dearmor | tee /etc/apt/trusted.gpg.d/debian-rpm-build-tools.gpg >/dev/null
    # Repository
    echo "deb [arch=${ARCH}] \
    https://kakwa.github.io/debian-rpm-build-tools/deb.${VERSION_CODENAME}.${ARCH}/ \
    ${VERSION_CODENAME} main" | \
      tee /etc/apt/sources.list.d/debian-rpm-build-tools.list
    # Update
    apt update

.. sourcecode:: bash

    # Install packages
    apt install mock createrepo-c rpm dnf gnupg2

RHEL/Rocky/Fedora
~~~~~~~~~~~~~~~~~

`.rpm` tools:

.. sourcecode:: bash

    dnf install make rpm-sign expect rpm-build createrepo mock wget

`.deb` tools:

.. sourcecode:: bash

    dnf install pbuilder apt dpkg debian-keyring ubu-keyring reprepro

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
