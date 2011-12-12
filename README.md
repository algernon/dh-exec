dh-exec
=======

[Debhelper][1] (in compat level 9 and above) allows its config files
to be executable, and uses the output of suchs scripts as if it was
the content of the config file.

This is a collection of scripts and programs to help creating
such scripts in a standardised and easy to understand fashion.

This collection provides two helpers, for the two most common tasks:

* Expanding variables in various [debhelper][1] files (either from the
environment, or variables known to dpkg-buildflags - including
multi-arch ones)
* Installing files from one location to another, with the possiblity
of renaming it

 [1]: http://kitenet.net/~joey/code/debhelper/
