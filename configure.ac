#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_INIT([dh-exec], [0.5], [algernon@debian.org])
AM_INIT_AUTOMAKE
AC_CONFIG_SRCDIR([src/dh-exec-subst.c])
AC_CONFIG_HEADERS([config.h])

AC_PROG_CC
PKG_PROG_PKG_CONFIG

PKG_CHECK_MODULES(LIBPIPELINE, libpipeline >= 1.2.0,,)

AC_CHECK_HEADERS([stdlib.h string.h unistd.h])
AC_CHECK_FUNCS([strerror])

AC_CONFIG_FILES([Makefile
                 lib/Makefile
                 src/Makefile
                 t/Makefile])
AC_OUTPUT
