#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_INIT([dh-exec], [0.22], [algernon@debian.org])
AM_INIT_AUTOMAKE([foreign subdir-objects])
m4_ifdef([AM_SILENT_RULES], [AM_SILENT_RULES([no])])

AC_CONFIG_SRCDIR([src/dh-exec.simple.c])
AC_CONFIG_HEADERS([config.h])

AC_PROG_CC
AC_PROG_CC_C_O
PKG_PROG_PKG_CONFIG

PKG_CHECK_MODULES(LIBPIPELINE, libpipeline >= 1.2.0,,)

AC_CHECK_HEADERS([stdlib.h string.h unistd.h])
AC_CHECK_FUNCS([setenv strdup strerror strstr])
AC_FUNC_MALLOC
AC_SYS_LARGEFILE

AC_CONFIG_FILES([Makefile])
AC_OUTPUT
