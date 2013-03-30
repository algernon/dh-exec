# --- Programs & scripts ---
bin_PROGRAMS		= src/dh-exec
pkglibexec_PROGRAMS	= src/dh-exec-subst \
			  src/dh-exec-install \
			  src/dh-exec-illiterate
man1_MANS		= src/dh-exec-subst.1 \
			  src/dh-exec-install.1 \
			  src/dh-exec-illiterate.1 \
			  src/dh-exec.1

pkgdata_SCRIPTS		= lib/dh-exec-subst-env \
			  lib/dh-exec-subst-multiarch \
			  lib/dh-exec-install-rename \
			  lib/dh-exec-illiterate-tangle

# --- Sources & flags ---
AM_CFLAGS		= ${LIBPIPELINE_CFLAGS}
AM_MAKEFLAGS		= --no-print-directory

LDADD			= ${LIBPIPELINE_LIBS}

src_dh_exec_SOURCES		= \
			src/dh-exec.c \
			src/dh-exec.lib.c \
			src/dh-exec.lib.h

src_dh_exec_subst_SOURCES	= \
			src/dh-exec.simple.c \
			src/dh-exec.lib.c \
			src/dh-exec.lib.h
src_dh_exec_subst_CFLAGS	= -DDH_EXEC_CMD=\"subst\"

src_dh_exec_install_SOURCES	= \
			src/dh-exec-install.c \
			src/dh-exec.lib.c \
			src/dh-exec.lib.h
src_dh_exec_install_CFLAGS	= -DDH_EXEC_CMD=\"install\"


src_dh_exec_illiterate_SOURCES	= \
			src/dh-exec.simple.c \
			src/dh-exec.lib.c \
			src/dh-exec.lib.h
src_dh_exec_illiterate_CFLAGS	= -DDH_EXEC_CMD=\"illiterate\"

# --- Test suite ---

TESTCASES_SUBST		= test_subst_syntax \
			  test_subst_env \
			  test_subst_multiarch
TESTCASES_INSTALL	= test_install_syntax \
			  test_install_copy
TESTCASES_ILLITERATE	= test_illiterate
TESTCASES_DH		= test_dh
TESTCASES_MISC		= test_combined test_help

TESTCASES		= ${TESTCASES_SUBST} ${TESTCASES_INSTALL} \
			${TESTCASES_MISC} ${TESTCASES_DH} \
			${TESTCASES_ILLITERATE}

TESTS_ENVIRONMENT	= DH_EXEC_SCRIPTDIR="${top_srcdir}/../lib" \
			DH_EXEC_LIBDIR="${top_builddir}/../src" \
			DH_EXEC_BINDIR="${top_builddir}/../src" \
			top_builddir="${top_builddir}/../" \
			srcdir="${srcdir}/t" \
			NO_PKG_MANGLE=1

pkgtest_FILES		= t/pkg-test/data/bin-arch \
			t/pkg-test/data/bin-foo \
			t/pkg-test/data/plugin-multiarch \
			t/pkg-test/debian/changelog \
			t/pkg-test/debian/compat \
			t/pkg-test/debian/control \
			t/pkg-test/debian/copyright \
			t/pkg-test/debian/pkg-test.dirs \
			t/pkg-test/debian/pkg-test-illiterate.dirs \
			t/pkg-test/debian/pkg-test-illiterate.install \
			t/pkg-test/debian/pkg-test.install \
			t/pkg-test/debian/rules \
			t/pkg-test/debian/source/format \
			t/pkg-test/GNUMakefile

check: ${TESTS}
	$(AM_V_GEN) ${TESTS_ENVIRONMENT} prove -e '' -f -o ${PROVE_OPTIONS} $(addprefix ${srcdir}/t/,${TESTCASES})

# --- Extra files to distribute ---

EXTRA_DIST		= README.md HACKING.md \
			${man1_MANS} ${pkgdata_SCRIPTS} \
			t/test.lib.sh \
			$(addprefix t/,${TESTCASES}) \
			${pkgtest_FILES} \
			${disabled_TESTCASES}
