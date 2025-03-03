Optional Setup & Troubleshooting
================================

Sudoers Configuration
---------------------

Building in chroot requires root permission.

If **make deb_chroot** is run as a standard user, **sudo** will be used for cowbuilder calls.

If you want to avoid password promt add the following line to the sudoers configuration:

.. sourcecode:: bash

    # replace build-user with the user used to generate the packages
    build-user ALL=(ALL) NOPASSWD: /usr/sbin/cowbuilder
    build-user ALL=(ALL) NOPASSWD: /usr/sbin/mock
    build-user ALL=(ALL) NOPASSWD: /usr/bin/mkdir -p /var/cache/pbuilder/*
    build-user ALL=(ALL) NOPASSWD: /usr/bin/rm -rf -- /var/cache/pbuilder/*

Repository Key Issues
---------------------

Cowbuilder requires the GPG keys of the targeted DIST.

If you get errors like `E: Release signed by unknown key (key id EF0F382A1A7B6500)`, try installing the keyrings:

.. sourcecode:: bash

    sudo apt install ubuntu-keyring debian-archive-keyring ubuntu-archive-keyring debian-keyring

Tmpfs
-----

If you have RAM to spare, using tmpfs mounts can significantly accelerate the build process.

One-time mount:

.. sourcecode:: bash

    # Mount tmpfs (as root)
    mount -t tmpfs -o size=16G tmpfs /var/cache/pbuilder/   # For cowbuilder/DEB builds
    mount -t tmpfs -o size=16G tmpfs /var/lib/mock          # For mock/RPM builds

fstab:

.. sourcecode:: bash

    # Or add to /etc/fstab for persistence
    tmpfs /var/cache/pbuilder/ tmpfs defaults,size=16G 0 0    # For combuilder/DEB builds
    tmpfs /var/lib/mock tmpfs defaults,size=16G 0 0           # For mock/RPM builds

Building on old distributions
-----------------------------

Modern distributions disable the syscall **vsyscall** used by older libc versions (RHEL <= 6, Debian <= 7).

You will see  errors like the following in **dmesg**:

.. sourcecode:: bash

    [  578.456176] sh[15402]: vsyscall attempted with vsyscall=none ip:ffffffffff600400 cs:33 sp:7ffd469c5aa8 ax:ffffffffff600400 si:7ffd469c6f23 di:0
    [  578.456180] sh[15402]: segfault at ffffffffff600400 ip ffffffffff600400 sp 00007ffd469c5aa8 error 15

To work around this issue, add the **vsyscall=emulate** option in the kernel command line.
