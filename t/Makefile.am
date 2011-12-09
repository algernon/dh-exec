AUTOMAKE_OPTIONS	= foreign

EXTRA_DIST		= test.lib.sh ${TESTCASES}

TESTCASES		= test_env
TESTS_ENVIRONMENT	= DH_SUBST_LIBDIR="${top_srcdir}/lib" top_builddir="${top_builddir}" \
			srcdir="${srcdir}"

check: ${TESTS}
	$(AM_V_GEN) ${TESTS_ENVIRONMENT} prove -e '' -f -o $(addprefix ./,${TESTCASES})
