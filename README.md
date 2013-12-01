dh-exec
=======

[![Build Status](https://secure.travis-ci.org/algernon/dh-exec.png?branch=master)](http://travis-ci.org/algernon/dh-exec)

[Debhelper][1] (in compat level 9 and above) allows its config files
to be executable, and uses the output of such scripts as if it was
the content of the config file.

This is a collection of scripts and programs to help creating
such scripts in a standardised and easy to understand fashion.

This collection provides solutions for the following tasks:

* Expanding variables in various [debhelper][1] files (either from the
  environment, or variables known to **dpkg-architecture**(1) -
  including multi-arch ones)
* An extension to dh_install, that supports renaming files during the
  copy process, using an extended syntax.

 [1]: http://kitenet.net/~joey/code/debhelper/

Usage
=====

The recommended way to use dh-exec is through the **dh-exec**(1)
wrapper, which will bind all the other tools together. That is, when
adding a she-bang line to an executable debhelper config file, use
`/usr/bin/dh-exec`.

Using dh-exec means one will need to use debhelper compat level 9 or
above and executable debhelper config files: there is no extra support
needed in `debian/rules` or elsewhere, just an executable file with an
appropriate she-bang line.

Advantages
==========

One may of course question the existence of a seemingly complicated
tool, all for achieving some variable substitution, something one
could do with a here-doc and a shell script. However, one would be
gravely mistaken thinking that it's all dh-exec does and what it is
good for.

A few major advantages dh-exec has over custom here-doc or sed magic
tricks:

* Compared to using sed or similar to generate debhelper control
  files, dh-exec does not require any changes in `debian/rules`, nor
  anywhere else but the scripts themselves.

  In most cases, it only needs a she-bang and an executable bit, and
  the former input file becomes a valid debhelper control file.

  This, in turn, makes the packaging simpler, as there is no
  package-specific magic involved anymore.

* Compared to the here-doc method, dh-exec provides consistency and
  safety.

  The most useful part of dh-exec (apart from adding rename support to
  .install files) is probably its support for expanding multiarch
  variables.

  dh-exec does this so that even if said variables are not set in the
  environment, it will query **dpkg-architecture**(1), so one can test
  the scripts without further setup.

  Of course, that is also doable with here-docs, but using variables
  seems more natural.

  dh-exec can also be asked to only substitute multiarch variables,
  not every environment variable, which makes it somewhat safer. It
  can't execute random shell commands either, which is another safety
  guard.

* dh-exec is one controlled tool in one place, as opposed to any
  number of diverse, package-specific hacks.

  Even if one does not need much from what dh-exec provides, using it
  instead of inventing one's own still has the advantage of being
  consistent accross packages.

  While it may be less powerful than a complete shell at ones command,
  it is also safer, and being a separate solution, not a
  package-specific hack, it does help overall, archive-wide
  consistency: if one knows what to expect from dh-exec, one will
  understand all dh-exec using packages. Package-specific hacks will
  always need a little bit extra work to understand and verify, while
  one only needs to understand dh-exec once.

Examples
========

One of the most simple cases is expanding multi-arch variables in an
install file:

    #! /usr/bin/dh-exec
    usr/lib/*.so.* /usr/lib/${DEB_HOST_MULTIARCH}/libsomething.so.*

Of course, this has the disadvantage of running all dh-exec scripts,
so it will also try to expand any environment variables too. For
safety, one can turn that off, and explicitly request that only
multi-arch expansion shall be done:

    #! /usr/bin/dh-exec --with-scripts=subst-multiarch
    usr/lib/*.so.* /usr/lib/${DEB_HOST_MULTIARCH}/libsomething.so.*
    /usr/share/doc/my-package/${HOME}-sweet-home

In this second case, the *${HOME}* variable will not be expanded, even
if such an environment variable is present when dh-exec runs.

Do note that dh-exec is not required at all if all you want to do is
mark a multi-arch path as belonging to a package: debhelper itself
supports wildcards! So if your install script would look like the
following:

    #! /usr/bin/dh-exec
    /usr/lib/${DEB_HOST_MULTIARCH}/libsomething.so.*

Then most likely, you do not need dh-exec, and you can replace the
above with this simple line:

    /usr/lib/*/libsomething.so.*

But variable expansion is not all that dh-exec is able to perform!
Suppose we want to install a file, under a different name: with
dh-exec, that is also possible:

    #! /usr/bin/dh-exec --with=install
    debian/default.conf => /etc/my-package/start.conf

These can, of course, be combined. One can even limit scripts to
multiarch substitution and install-time renaming only, skipping
everything else dh-exec might try:

    #! /usr/bin/dh-exec --with-scripts=subst-multiarch,install-rename
    configs/config-${DEB_HOST_GNU_TYPE}.h => /usr/include/${DEB_HOST_MULTIARCH}/package/config.h

-- 
Gergely Nagy <algernon@debian.org>
