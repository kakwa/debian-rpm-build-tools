# -*- coding: utf-8 -*-
# vim:expandtab:autoindent:tabstop=4:shiftwidth=4:filetype=python:textwidth=0:
# License: GPL2 or later see COPYING

import os.path
import sys

VERSION = "6.0"  
SYSCONFDIR = "/etc/"
PYTHONDIR = os.path.dirname(os.path.realpath(sys.argv[0]))
import mockbuild
PKGPYTHONDIR = os.path.dirname(mockbuild.__file__)
MOCKCONFDIR = os.path.join(SYSCONFDIR, "mock")
