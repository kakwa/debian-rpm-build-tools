.. include:: ../../README.rst
    :start-after: .. build_deps_start
    :end-before: .. quick_ref

Cross-Architecture Builds
~~~~~~~~~~~~~~~~~~~~~~~~~

Debian/Ubuntu:

.. sourcecode:: bash

    # Adapt with the architectures you are targetting
    apt install binfmt-support qemu-utils qemu-user-static qemu-system-arm qemu-system-misc qemu-system-ppc qemu-system-s390x

RHEL/Rocky/Fedora:

.. sourcecode:: bash

    # customize with your archs
    dnf install qemu-user-binfmt qemu-system-riscv qemu-system-aarch64

Repository Initialization
-------------------------

Create a bare repo and run the following:

.. sourcecode:: bash

    # Set with your bare git repository uri
    REPO_URL=git@github.com:user/your-awesome-packages

    REPO_DIR=$(basename ${REPO_URL} | sed 's/\.git$//')

    git clone https://github.com/kakwa/pakste "${REPO_DIR}"
    cd "${REPO_DIR}"

    git remote remove origin
    git remote add origin $REPO_URL

    git push origin main

Updating Pakste
---------------

To update Pakste in your repository, run:

.. sourcecode:: bash

    make update
