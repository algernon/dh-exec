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

Hacking
=======

Adding helpers to dh-exec can be done in two ways: either by adding a
completely new **dh-exec-_$foo_** tool, or extending an already
existing one, by adding a new **dh-exec-$foo-_$magic_** command under
libs/.

The way dh-exec works, is that the top-level commands are compiled
binaries, which assemble a pipeline of all of their subcommands, and
pass their argument as stdin to all of them in turn, in alphabetical
order.

Helper functions to assist with these tasks are contained in the
_src/dh-exec.lib.c_ and _src/dh-exec.lib.h_ files.

The top-level commands **must** set the *DH\_EXEC\_SOURCE* environment
variable to the name of the input file. The sub-commands must be able
to assume that this variable is set, so that they can figure out the
filename of the source. They **must not** touch that file directly,
but read from their standard input instead. But they can make
decisions based on the filename.

The sub-commands need to read their input from stdin, and output the
result to stdout. The only guaranteed variable set in the environment
is *DH\_EXEC\_SOURCE*.

Another environment variable we must care about - in the top-level
commands' implementations - is *DH\_EXEC\_SCRIPTDIR*, which is the
directory under which the sub-commands will be searched. It need not
be specified, as the default is what it should be. But for the
testsuite to work, it needs to be overridable.

Modifications
=============

Since the purpose of this collection is **standardization**, if one
wants to change or add something, run it by me **first**, even if it's
not useful for Debian just yet.

I will not accept features that have been added to a fork already, and
are being used by existing packages. That makes the whole thing
pointless.

There are of course exceptions, such as bugfixes. But in general, the
way to get new features or incompatible changes into dh-exec is
through me. Either directly, or - once the package is in Debian -
through the BTS.

-- 
Gergely Nagy <algernon@debian.org>
