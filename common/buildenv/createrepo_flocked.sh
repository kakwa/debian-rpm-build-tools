#!/bin/sh

set -x

LOCKFILE="/tmp/createrepo.lock"
flock -w 120 "${LOCKFILE}" createrepo_c "$@"
