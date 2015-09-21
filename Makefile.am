# --- Default paths ---
DH_EXEC_SCRIPTDIR	?= ${pkgdatadir}
DH_EXEC_LIBDIR		?= ${pkglibexecdir}

# --- Programs & scripts ---
bin_PROGRAMS		= src/dh-exec
pkglibexec_PROGRAMS	= src/dh-exec-subst \
			  src/dh-exec-install \
			  src/dh-exec-illiterate \
			  src/dh-exec-strip \
			  src/dh-exec-filter
man1_MANS		= src/dh-exec-subst.1 \
			  src/dh-exec-install.1 \
			  src/dh-exec-illiterate.1 \
			  src/dh-exec-filter.1 \
			  src/dh-exec.1

pkgdata_SCRIPTS		= lib/dh-exec-subst-env \
			  lib/dh-exec-subst-multiarch \
			  lib/dh-exec-install-rename \
			  lib/dh-exec-illiterate-tangle \
			  lib/dh-exec-strip-output \
			  lib/dh-exec-filter-arch \
			  lib/dh-exec-filter-comments \
			  lib/dh-exec-filter-build-profiles

# --- Sources & flags ---
AM_CFLAGS		= ${LIBPIPELINE_CFLAGS} \
			-DDH_EXEC_SCRIPTDIR="\"${DH_EXEC_SCRIPTDIR}\"" \
			-DDH_EXEC_LIBDIR="\"${DH_EXEC_LIBDIR}\""
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

src_dh_exec_strip_SOURCES	= \
			src/dh-exec.simple.c \
			src/dh-exec.lib.c \
			src/dh-exec.lib.h
src_dh_exec_strip_CFLAGS	= -DDH_EXEC_CMD=\"strip\" \
				  -DDH_EXEC_CMD_ALWAYS=1

src_dh_exec_filter_SOURCES	= \
			src/dh-exec.simple.c \
			src/dh-exec.lib.c \
			src/dh-exec.lib.h
src_dh_exec_filter_CFLAGS	= -DDH_EXEC_CMD=\"filter\" \
				  -DDH_EXEC_CMD_ALWAYS=1

# --- Test suite ---

TESTCASES_SUBST		= test_subst_syntax.bats \
			  test_subst_env.bats \
			  test_subst_multiarch.bats
TESTCASES_INSTALL	= test_install_syntax.bats \
			  test_install_copy.bats
TESTCASES_ILLITERATE	= test_illiterate.bats
TESTCASES_DH		= test_dh.bats
TESTCASES_MISC		= test_combined.bats \
			  test_dh_exec.bats \
			  test_strip.bats \
			  test_filter.bats

TESTCASES		= ${TESTCASES_SUBST} ${TESTCASES_INSTALL} \
			${TESTCASES_MISC} ${TESTCASES_DH} \
			${TESTCASES_ILLITERATE}

TESTS_ENVIRONMENT	= DH_EXEC_SCRIPTDIR="${top_srcdir}/lib" \
			DH_EXEC_LIBDIR="${top_builddir}/src" \
			DH_EXEC_BINDIR="${top_builddir}/src" \
			top_builddir="${top_builddir}/" \
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

check: all $(addprefix ${top_srcdir}/t/,${TESTCASES})
	$(AM_V_GEN) ${TESTS_ENVIRONMENT} \
		prove -e "bats --tap" -f \
		      -o ${PROVE_OPTIONS} \
		      $(addprefix ${top_srcdir}/t/,${TESTCASES})

bats: all $(addprefix ${top_srcdir}/t/,${TESTCASES})
	${AM_V_GEN} ${TESTS_ENVIRONMENT} \
		    bats ${BATS_OPTIONS} \
		      $(addprefix ${top_srcdir}/t/,${TESTCASES})

# -- Custom targets --
coverage: coverage.info.html

coverage.info.html: coverage.info
	$(AM_V_GEN)genhtml --quiet $^ --output-directory $@

coverage.info: check
	$(AM_V_GEN)lcov --quiet --capture --directory ${top_builddir}/src --output $@ -b ${top_builddir}

.PHONY: coverage
CLEANFILES		= coverage.info

clean-local:
	rm -rf coverage.info.html
	find ${top_builddir} -name '*.gcda' -or -name '*.gcno' | xargs rm -f

# --- Extra files to distribute ---

EXTRA_DIST		= README.md CONTRIBUTING.md \
			${man1_MANS} ${pkgdata_SCRIPTS} \
			t/test.lib.bash \
			$(addprefix t/,${TESTCASES}) \
			${pkgtest_FILES} \
			${disabled_TESTCASES}
