dh-exec
=======

[![Build Status](https://img.shields.io/travis/algernon/dh-exec/master.svg?style=flat-square)](https://travis-ci.org/algernon/dh-exec)

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
* Another extension to dh_install, allowing one to move a file to one package,
  and copy the rest to another.
* Ability to filter files by architecture or build profile, within a
  single debhelper control file.

 [1]: https://tracker.debian.org/pkg/debhelper

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

* A declarative syntax, familiar to everyone who used debhelper and
  other debian tools.

  One can employ architecture or build profile restrictions in
  executable scripts just as one does in `debian/control`.

* A single tool that does the heavy lifting for you, just like
  debhelper does.

  Instead of repeating similar code across a number of packages, a
  simple build-dependency on a helper tool gets you a lot more, for a
  fraction of the price.

* It is reliable, stable and in active use.

  As of this writing, there are over a hundred packages
  build-depending on `dh-exec`, and using parts of its feature sets,
  and the number keeps growing.

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

But variable expansion is not all that dh-exec is able to perform!
Suppose we want to install a file, under a different name: with
dh-exec, that is also possible:

    #! /usr/bin/dh-exec --with=install
    debian/default.conf => /etc/my-package/start.conf

These can, of course, be combined. One can even limit scripts to
multiarch substitution and install-time renaming only, skipping
everything else dh-exec might try:

    #! /usr/bin/dh-exec --with-scripts=subst-multiarch,install-rename
    cfgs/cfg-${DEB_HOST_GNU_TYPE}.h => /usr/include/${DEB_HOST_MULTIARCH}/package/config.h

Additionally, assuming we have two binary packages: `foo-gtk` and `foo-utils`,
and we want to include `/usr/bin/foo-gtk` in the former package, the rest of
`/usr/bin` in the latter. Our install files would look like these, for `foo-gtk`
and `foo-utils` respectively:

    #! /usr/bin/dh-exec
    => /usr/bin/foo-gtk
    
    #! /usr/bin/dh-exec
    /usr/bin/*

But wait, there's more! You can restrict lines based on architecture,
or build profile:

    #! /usr/bin/dh-exec
    [linux-any] usr/bin/linux-*
    [!freebsd-any] lib/systemd/system/*
    <stage1> usr/bin/compiler1

When not to use dh-exec
=======================

Do note that dh-exec is not required at all if all you want to do is
mark a multi-arch path as belonging to a package: debhelper itself
supports wildcards! So if your install script would look like the
following:

    #! /usr/bin/dh-exec
    usr/lib/${DEB_HOST_MULTIARCH}/libsomething.so.*

Then most likely, you do not need dh-exec, and you can replace the
above with this simple line:

    usr/lib/*/libsomething.so.*

Similarly, all of the following can be simplified to using wildcards,
unless there's another directory under `/usr/lib` which one doesn't
want to install:

    #! /usr/bin/dh-exec
    usr/lib/${DEB_HOST_MULTIARCH}
    usr/lib/${DEB_HOST_MULTIARCH}/pkgconfig/*.pc usr/lib/${DEB_HOST_MULTIARCH}/pkgconfig

-- 
Gergely Nagy <algernon@debian.org>
