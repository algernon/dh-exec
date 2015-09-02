Hacking
=======

Adding functionality to dh-exec can be done in two ways: either by
adding a completely new **dh-exec-_$foo_** sub-command, or extending
an already existing one, by adding a new **dh-exec-$foo-_$magic_**
script under `libs/`.

The way dh-exec works, is that the top-level sub-commands are compiled
binaries, which assemble a pipeline of all of their scripts, and pass
their argument as stdin to all of them in turn, in alphabetical order.

Helper functions to assist with these tasks are contained in the
`src/dh-exec.lib.c` and `src/dh-exec.lib.h` files.

The top-level sub-commands **must** set the *DH\_EXEC\_SOURCE*
environment variable to the name of the input file. The scripts must
be able to assume that this variable is set, so that they can figure
out the filename of the source. They **must not** touch that file
directly, but read from their standard input instead. But they can
make decisions based on the filename.

The scripts need to read their input from stdin, and output the result
to stdout. The only guaranteed variable set in the environment is
*DH\_EXEC\_SOURCE*.

Another environment variable we must care about - in the top-level
sub-commands' implementations - is *DH\_EXEC\_SCRIPTDIR*, which is the
directory under which the scripts will be searched. It need not be
specified, as the default is what it should be. But for the testsuite
to work, it needs to be overridable.

There is one final environment variable the various sub-commands (but
not the actual scripts) must care about: *DH\_EXEC\_SCRIPTS*. When
this variable is set, it contaisn a list of scripts to run (without
the *dh-exec-* prefix), and the sub-commands must check that from the
set of scripts they would run, only those get run that are in the
list. This allows users to limit exactly which scripts end up running.

In case a sub-command finds that it would not run anything, it should
run cat instead, to not loose its stdin.

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
through me. Either directly, or through the Debian BTS.

-- 
Gergely Nagy <algernon@debian.org>
