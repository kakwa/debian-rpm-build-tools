.. include:: ../../README.rst
    :start-after: .. build_deps_start
    :end-before: .. quick_ref

Cross-Architecture Builds
~~~~~~~~~~~~~~~~~~~~~~~~~

Debian/Ubuntu:

.. sourcecode:: bash

    # Adapt with the CPU architectures you are targetting
    apt install binfmt-support qemu-utils qemu-user-static \
        qemu-system-arm qemu-system-misc qemu-system-ppc qemu-system-s390x

RHEL/Rocky/Fedora:

.. sourcecode:: bash

    # customize with your archs
    dnf install qemu-user-binfmt qemu-system-riscv qemu-system-aarch64

Repository Initialization
-------------------------

Create git repository (most likely on Github) and checkout it:

.. sourcecode:: bash

    # Clone and cd in your repository
    export REPO_URL=<your git url>
    git clone ${REPO_URL}
    cd $(basename ${REPO_URL} | sed 's/\.git$//')

Recover Pakste:

.. sourcecode:: bash

    # Download Pakste
    wget -qO- https://github.com/kakwa/pakste/archive/refs/heads/main.tar.gz | \
        tar --strip-components=1 -xz

Optionally, create **README.md**:

.. sourcecode:: bash

    # Set with your org/user and repo name
    export GH_ORG=<your gh org/user>
    export GH_REPO=<your gh repo name>

    # Copy configuration example
    cp common/README.md.ex README.md

    # Customize for your repo
    sed -i "s/@ORG@/${GH_ORG}/g" README.md
    sed -i "s/@REPO@/${GH_REPO}/g" README.md

    # Tweak it if necessary
    vim README.md

Commit:

.. sourcecode:: bash

    # Commit
    git add ./
    git commit -a -m 'init'
    git push origin main

.. warning::

    Don't customize the following files & directory:

    * ``common/``
    * ``.github/workflows/build-test.yml``
    * ``.github/workflows/repos.yml``
    * ``.github/workflows/vulncheck.yml``
    * ``.github/workflows/docs.yml``
    * ``Makefile``
    * ``README.rst``
    
    These resources are overwritten during Pakste updates.
