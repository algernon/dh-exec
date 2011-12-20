AUTOMAKE_OPTIONS	= foreign

bin_PROGRAMS		= dh-exec
pkglib_PROGRAMS		= dh-exec-subst dh-exec-install dh-exec-illiterate

man1_MANS		= dh-exec-subst.1 dh-exec.1 dh-exec-install.1 \
			dh-exec-illiterate.1

EXTRA_DIST		= ${man1_MANS}

dh_exec_SOURCES		= dh-exec.c dh-exec.lib.c dh-exec.lib.h
dh_exec_CFLAGS		= @LIBPIPELINE_CFLAGS@
dh_exec_LDADD		= @LIBPIPELINE_LIBS@

dh_exec_subst_SOURCES	= dh-exec-subst.c dh-exec.lib.c dh-exec.lib.h
dh_exec_subst_CFLAGS	= @LIBPIPELINE_CFLAGS@
dh_exec_subst_LDADD	= @LIBPIPELINE_LIBS@

dh_exec_install_SOURCES	= dh-exec-install.c dh-exec.lib.c dh-exec.lib.h
dh_exec_install_CFLAGS	= @LIBPIPELINE_CFLAGS@
dh_exec_install_LDADD	= @LIBPIPELINE_LIBS@

dh_exec_illiterate_SOURCES = dh-exec-illiterate.c dh-exec.lib.c dh-exec.lib.h
dh_exec_illiterate_CFLAGS  = @LIBPIPELINE_CFLAGS@
dh_exec_illiterate_LDADD   = @LIBPIPELINE_LIBS@
