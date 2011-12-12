AUTOMAKE_OPTIONS	= foreign

EXTRA_DIST		= test.lib.sh ${TESTCASES}

TESTCASES		= test_env test_multiarch
TESTS_ENVIRONMENT	= DH_EXEC_LIBDIR="${top_srcdir}/lib" top_builddir="${top_builddir}" \
			srcdir="${srcdir}"

check: ${TESTS}
	$(AM_V_GEN) ${TESTS_ENVIRONMENT} prove -e '' -f -o $(addprefix ./,${TESTCASES})
