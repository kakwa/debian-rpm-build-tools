.. include:: ../../README.rst
    :start-after: .. build_deps_start
    :end-before: .. quick_ref

Cross-Architecture Builds
~~~~~~~~~~~~~~~~~~~~~~~~~

Debian/Ubuntu:

.. sourcecode:: bash

    # Adapt with the architectures you are targetting
    apt install binfmt-support qemu-utils qemu-user-static \
        qemu-system-arm qemu-system-misc qemu-system-ppc qemu-system-s390x

RHEL/Rocky/Fedora:

.. sourcecode:: bash

    # customize with your archs
    dnf install qemu-user-binfmt qemu-system-riscv qemu-system-aarch64

Repository Initialization
-------------------------

Create a **bare*** git repository (most likely on github) and run the following commands:

.. sourcecode:: bash

    # Set with your bare git repository uri
    export REPO_URL=<your git url>

    export REPO_DIR=$(basename ${REPO_URL} | sed 's/\.git$//')
    git clone https://github.com/kakwa/pakste "${REPO_DIR}"
    cd "${REPO_DIR}"
    git remote remove origin
    git remote add origin $REPO_URL
    git push origin main

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

Updating Pakste
---------------

To update Pakste in your repository, run:

.. sourcecode:: bash

    make update
