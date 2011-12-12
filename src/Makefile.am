AUTOMAKE_OPTIONS	= foreign

bin_PROGRAMS		= dh-exec-subst dh-exec-install

dh_exec_subst_SOURCES	= dh-exec-subst.c dh-exec.c dh-exec.h
dh_exec_subst_CFLAGS	= @LIBPIPELINE_CFLAGS@
dh_exec_subst_LDADD	= @LIBPIPELINE_LIBS@

dh_exec_install_SOURCES	= dh-exec-install.c dh-exec.c dh-exec.h
dh_exec_install_CFLAGS	= @LIBPIPELINE_CFLAGS@
dh_exec_install_LDADD	= @LIBPIPELINE_LIBS@
