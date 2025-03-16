Repository
==========

Building Repositories
---------------------

Preparation
~~~~~~~~~~~

.. sourcecode:: bash

    # Optional: Clean everything before building
    make clean

    # Optional: Clean but keep upstream sources
    make clean KEEP_CACHE=true

Building DEB Repository
~~~~~~~~~~~~~~~~~~~~~~~

.. sourcecode:: bash

    # Build for specific distribution
    make deb_repo DIST=bullseye

    # Build with parallel jobs
    make deb_repo -j4 DIST=bullseye

    # Continue on package build failures
    make deb_repo DIST=bullseye ERROR=skip

Building RPM Repository
~~~~~~~~~~~~~~~~~~~~~~~

.. sourcecode:: bash

    # Build for specific distribution
    make rpm_repo -j4 DIST=el9

Publishing Repositories
-----------------------

The repositories can be published via HTTP server or other methods:

.. sourcecode:: bash

    # Example: Copy to web server
    rsync -avz out/ user@server:/var/www/repos/
