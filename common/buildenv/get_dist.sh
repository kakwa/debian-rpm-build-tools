#!/bin/sh

case $1 in
  # Debian code names:
  wheezy)
    echo 7:deb:debian-7; exit 0;;
  jessie)
    echo 8:deb:debian-8; exit 0;;
  stretch)
    echo 9:deb:debian-9; exit 0;;
  buster)
    echo 10:deb:debian-10; exit 0;;
  bullseye)
    echo 11:deb:debian-11; exit 0;;
  bookworm)
    echo 12:deb:debian-12; exit 0;;
  trixie)
    echo 13:deb:debian-13; exit 0;;
  sid)
    echo 14:deb:debian-14; exit 0;;

  # Ubuntu code names:
  precise)
    echo 12.4:ubu:ubuntu-12.4; exit 0;;
  trusty)
    echo 14.4:ubu:ubuntu-14.4; exit 0;;
  vivid)
    echo 15.4:ubu:ubuntu-15.4; exit 0;;
  wily)
    echo 15.10:ubu:ubuntu-15.10; exit 0;;
  xenial)
    echo 16.4:ubu:ubuntu-16.4; exit 0;;
  yakkety)
    echo 16.10:ubu:ubuntu-16.10; exit 0;;
  zesty)
    echo 17.4:ubu:ubuntu-17.4; exit 0;;
  artful)
    echo 17.10:ubu:ubuntu-17.10; exit 0;;
  bionic)
    echo 18.4:ubu:ubuntu-18.4; exit 0;;
  cosmic)
    echo 18.10:ubu:ubuntu-18.10; exit 0;;
  disco)
    echo 19.4:ubu:ubuntu-19.4; exit 0;;
  eoan)
    echo 19.10:ubu:ubuntu-19.10; exit 0;;
  focal)
    echo 20.4:ubu:ubuntu-20.4; exit 0;;
  groovy)
    echo 20.10:ubu:ubuntu-20.10; exit 0;;
  hirsute)
    echo 21.4:ubu:ubuntu-21.4; exit 0;;
  impish)
    echo 21.10:ubu:ubuntu-21.10; exit 0;;
  jammy)
    echo 22.4:ubu:ubuntu-22.4; exit 0;;
  impish)
    echo 22.10:ubu:ubuntu-22.10; exit 0;;
  kinetic)
    echo 23.4:ubu:ubuntu-23.4; exit 0;;
  lunar)
    echo 23.10:ubu:ubuntu-23.10; exit 0;;
  noble)
    echo 24.4:ubu:ubuntu-24.4; exit 0;;
esac
echo 0:unk;
