dh-exec
=======

[Debhelper][1] (in compat level 9 and above) allows its config files
to be executable, and uses the output of suchs scripts as if it was
the content of the config file.

This is a collection of scripts and programs to help creating
such scripts in a standardised and easy to understand fashion.

This collection provides helpers for the following tasks:

* Expanding variables in various [debhelper][1] files (either from the
environment, or variables known to dpkg-architecture - including
multi-arch ones)
* An extension to dh_install, that supports renaming files during the
copy process, using an extended syntax.

 [1]: http://kitenet.net/~joey/code/debhelper/

Usage
=====

The recommended way to use dh-exec is through the **dh-exec**(1)
wrapper, which will bind all the other tools together. That is, when
adding a she-bang line to an executable debhelper config file, use
/usr/bin/dh-exec.

-- 
Gergely Nagy <algernon@debian.org>
