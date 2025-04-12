Troubleshooting
===============

Troubleshooting The Build
-------------------------

If you need to troubleshoot the build in the chroot, run the ``<PKG>_shell_chroot``.

This trigger a build and spawn a shell in case of failure, enabling you to troubleshoot from there:

.. sourcecode:: bash

    # Deb version
    make deb_shell_chroot DIST=trixie

    # rpm version
    make rpm_shell_chroot DIST=el9

Checksum Error
--------------

In case of checksum mismatch, an error like the following one will be displayed:

.. sourcecode:: bash

    [ERROR] Bad checksum for 'https://github.com/kakwa/mk-sh-skel/archive/1.0.0.tar.gz'
    expected: 2cdeaa0cd4ddf624b5bc7ka5dbdeb4c3dbe77df09eb58bac7621ee7b
    got:      1cdea044ddf624b5bc7465dbdeb4c3dbe77df09eb58bac7621ee7b64

This is indicative that the upstream source archive has been altered and should be **investigated**.

If the change is legitimate, then rebuild the MANIFEST:

.. sourcecode:: bash

    make manifest

.. note::

    In case the manifest in missing, you will get the following error (same fix applies):

   .. sourcecode:: bash
      
      [ERROR] No checksum found in manifest for mk-sh-skel-1.4.9.tar.gz

Repository Key Issues
---------------------

Cowbuilder requires the GPG keys of the targeted DIST.

If you get errors like `E: Release signed by unknown key (key id EF0F382A1A7B6500)`, try installing the keyrings:

.. sourcecode:: bash

    apt install ubuntu-keyring debian-archive-keyring \
        ubuntu-archive-keyring debian-keyring

Building on old distributions
-----------------------------

Modern distributions disable the syscall **vsyscall** used by older libc versions (RHEL <= 6, Debian <= 7).

You will see errors like the following in **dmesg**:

.. sourcecode:: bash

    vsyscall attempted with vsyscall=none ip:ffffffffff600400 cs:33 sp:7ffd469c5aa8 ax:ffffffffff600400 si:7ffd469c6f23 di:0
    segfault at ffffffffff600400 ip ffffffffff600400 sp 00007ffd469c5aa8 error 15

To work around the issue, add the ``vsyscall=emulate`` option in the kernel command line.
