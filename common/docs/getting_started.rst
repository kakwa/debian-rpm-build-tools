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

Create your own **bare*** git repository and run the following:

.. sourcecode:: bash

    # Set with your bare git repository uri
    REPO_URL=git@github.com:user/your-awesome-packages

    REPO_DIR=$(basename ${REPO_URL} | sed 's/\.git$//')

    git clone https://github.com/kakwa/pakste "${REPO_DIR}"
    cd "${REPO_DIR}"

    git remote remove origin
    git remote add origin $REPO_URL

    git push origin main

Repository Configuration
------------------------

If you don't have one, create a GPG signing key (leave the password empty):

.. sourcecode:: bash

    # Generate a new GPG key
    gpg --gen-key

Create **Makefile.config** and set the repository metadata:

.. sourcecode:: bash

    # copy configuration example
    cp common/Makefile.config.ex Makefile.config

    # tweak it
    vim Makefile.config

Optionally, create **README.md**:

.. sourcecode:: bash

    # copy configuration example
    cp common/README.md.ex README.md

    # Customize for your repo
    sed -i 's/@ORG@/<name of your github org/user>/g' README.md
    sed -i 's/@REPO@/<name your github repository>/g' README.md

    # tweak it if necessary
    vim README.md

Updating Pakste
---------------

To update Pakste in your repository, run:

.. sourcecode:: bash

    make update
