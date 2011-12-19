AUTOMAKE_OPTIONS	= foreign

pkglib_PROGRAMS		= dh-exec-subst dh-exec dh-exec-install

dh_exec_SOURCES		= dh-exec.c dh-exec.lib.c dh-exec.lib.h
dh_exec_CFLAGS		= @LIBPIPELINE_CFLAGS@
dh_exec_LDADD		= @LIBPIPELINE_LIBS@

dh_exec_subst_SOURCES	= dh-exec-subst.c dh-exec.lib.c dh-exec.lib.h
dh_exec_subst_CFLAGS	= @LIBPIPELINE_CFLAGS@
dh_exec_subst_LDADD	= @LIBPIPELINE_LIBS@

dh_exec_install_SOURCES	= dh-exec-install.c dh-exec.lib.c dh-exec.lib.h
dh_exec_install_CFLAGS	= @LIBPIPELINE_CFLAGS@
dh_exec_install_LDADD	= @LIBPIPELINE_LIBS@
