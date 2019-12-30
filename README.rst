Decription
----------

This repository contains .deb (Debian) packaging scripts of RHEL/CentOS/Fedora packaging tools (mock, dnf, createrepo_c).

Status
------

These tools seems to work fine up to EL7, but building for EL8 packages saddly doesn't work yet, and newer Fedora releases are likely to suffer the same issue.

Packaging documentation in a nutshell
-------------------------------------

.. sourcecode:: bash
    
  # Install the packaing tools
  $ apt-get install make debhelper reprepro cowbuilder wget

  # gpg key generation (one time thing)
  $ gpg --gen-key
  
  # editing the global configuration (edit the gpg key and packager name)
  $ vim common/buildenv/Makefile.config

  # build for Debian buster
  $ make deb_repo DIST=buster -j4

  # build for Debian sid
  $ make deb_repo DIST=sid -j4

These packaging scripts reuses the amkecpak framework. If you need more information, read the `detailed documentation <http://amkecpak.readthedocs.org/en/latest/>`_.

Repository
----------

The generated packages are available here:

* https://mirror.kakwalab.ovh/debian-rpm-build-tools/

To install the repository:

.. sourcecode:: bash

  # Set the distribution code name:
  export DIST=buster

  # Add the GPG key
  wget -qO - https://mirror.kakwalab.ovh/debian-rpm-build-tools/GPG-KEY.pub | apt-key add -

  # Add the repository
  echo "deb [arch=amd64] http://mirror.kakwalab.ovh/debian-rpm-build-tools/deb.${DIST}/ ${DIST} main" >/etc/apt/sources.list.d/rpm-build-tools.list

  # Install the rpm building tools
  apt install dnf createrepo-c mock
