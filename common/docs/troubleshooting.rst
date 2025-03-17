Optional Setup & Troubleshooting
================================

Sudoers Configuration
---------------------

Building in chroot requires root permission.

If ``make deb_chroot``/``make rpm_chroot`` is run as a standard user, **sudo** will be used for cowbuilder calls.

If you want to avoid password promt add the following line to the sudoers configuration:

.. sourcecode:: bash

    # replace build-user with the user used to generate the packages
    <BUILD_USER> ALL=(ALL) NOPASSWD: /usr/sbin/cowbuilder
    <BUILD_USER> ALL=(ALL) NOPASSWD: /usr/sbin/pbuilder
    <BUILD_USER> ALL=(ALL) NOPASSWD: /usr/sbin/mock
    <BUILD_USER> ALL=(ALL) NOPASSWD: /usr/bin/mkdir -p /var/cache/pbuilder/*
    <BUILD_USER> ALL=(ALL) NOPASSWD: /usr/bin/rm -rf -- /var/cache/pbuilder/*

Internet Access During Build
----------------------------

By default, ``mock``/``pbuilder`` build environments don't have internet access.

If you need access (for example, to use `go get` or `npm install`), add the following in your package ``Makefile``:

.. sourcecode:: make

    COWBUILD_BUILD_ADDITIONAL_ARGS=--use-network yes
    MOCK_BUILD_ADDITIONAL_ARGS=--enable-network

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

GPG Key
-------

Packages are signed with a GPG key. Here are essential commands for key management:

.. sourcecode:: bash

    GPG_KEY="GPG_SIGNKEY"

    # Generate a new GPG key
    gpg --gen-key

    # List available keys
    gpg -K

    # Export private key (for multiple build hosts)
    gpg --export-secret-key -a "${GPG_KEY}" > priv.gpg

    # Import private key on another system
    gpg --import priv.gpg

    # Export public key
    gpg --armor --output $(OUT_DIR)/GPG-KEY.pub --export "${GPG_KEY}"

    # Import public key into apt (for testing)
    cat public.gpg | apt-key add -

Building on old distributions
-----------------------------

Modern distributions disable the syscall **vsyscall** used by older libc versions (RHEL <= 6, Debian <= 7).

You will see  errors like the following in **dmesg**:

.. sourcecode:: bash

    [  578.456176] sh[15402]: vsyscall attempted with vsyscall=none ip:ffffffffff600400 cs:33 sp:7ffd469c5aa8 ax:ffffffffff600400 si:7ffd469c6f23 di:0
    [  578.456180] sh[15402]: segfault at ffffffffff600400 ip ffffffffff600400 sp 00007ffd469c5aa8 error 15

To work around this issue, add the **vsyscall=emulate** option in the kernel command line.
