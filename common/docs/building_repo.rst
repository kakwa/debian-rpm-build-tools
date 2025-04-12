Repository
==========

GitHub Actions & Github Pages Automation
----------------------------------------

Repository Configuration
~~~~~~~~~~~~~~~~~~~~~~~~

If you don't have one, create a GPG signing key (leave the password empty):

.. sourcecode:: bash

    # Generate a new GPG key
    gpg --gen-key

Create **Makefile.config** and set the repository metadata, in particular ``GPG_KEY`` and ``DEB_ALL_TARGETS``/``RPM_ALL_TARGETS``:

.. sourcecode:: bash

    # Copy configuration example
    cp common/Makefile.config.ex Makefile.config

    # Tweak it
    vim Makefile.config

Finally, commit & push ``Makefile.config``.

Setting Up Automated Builds
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Pakste includes a GitHub Actions workflow that automatically builds and publishes package repositories.

This workflow builds packages for all architectures and distributions declared in ``Makefile.config``, then publishes them to GitHub Pages.

To set up this automation in your repository:

1. **Enable GitHub Pages**:

   - Go to your repository on GitHub
   - Navigate to Settings → Pages
   - Under "Build and deployment", select "GitHub Actions" as the source
   - Take note of the Github Pages URL.

2. **Configure GPG Signing Key**:

   - Export your GPG private key:

     .. sourcecode:: bash

         gpg --export-secret-keys --armor YOUR_KEY_ID

   - Add this key as a repository secret:
     - Go to repository Settings → Secrets and variables → Actions
     - Create a new repository secret named ``GPG_SIGNING_KEY``
     - Paste your exported GPG key as the value

3. **Enable the Workflow**:

   - By default, the workflow runs when you push to the main branch
   - You can also manually trigger it from the Actions tab in your repository

Disabling TMPFS Builds
~~~~~~~~~~~~~~~~~~~~~~

By default, a tmpfs is used for the build.

If you have ram and/or space intensive builds (commulated >16GB), you can disable it:

1. Go to repository Settings → Secrets and variables → Actions → Variables
2. Create a new variable named ``NO_TMPFS`` with value ``true``

Disabling the Workflow
~~~~~~~~~~~~~~~~~~~~~~

If you need to disable the workflow:

1. Go to repository Settings → Secrets and variables → Actions → Variables
2. Create a new variable named ``REPO_WORKFLOW_DISABLED`` with value ``true``

Building Locally
----------------

Preparation
~~~~~~~~~~~

.. sourcecode:: bash

    # Optional: Clean everything before building
    make clean

    # Optional: Clean but keep upstream sources
    make clean KEEP_CACHE=true

Building Specific .deb Repository
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Build .deb repo for a specific distribution:

.. sourcecode:: bash

    # (uncomment ERROR=skip to continue on package build failures)
    make deb_repo -j4 DIST=trixie # ERROR=skip

Building Specific .deb Repository
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Build .rpm repo for a specific distribution:

.. sourcecode:: bash

    make rpm_repo -j1 DIST=el9 # ERROR=skip

Building All Repositories
~~~~~~~~~~~~~~~~~~~~~~~~~

Building all rpm/deb targets declared in ``Makefile.config``:

.. sourcecode:: bash

    # All deb repositories
    make deb_all_repos -j4

    # All rpm repositories
    make rpm_all_repos -j4

Build all targets declared in ``Makefile.config``:

.. sourcecode:: bash

    make all_repos

.. note::

    From there, you can publish the ``out/`` directory on any static http hosting (S3, nginx, etc).
