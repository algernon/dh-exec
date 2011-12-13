AUTOMAKE_OPTIONS	= foreign

EXTRA_DIST		= test.lib.sh ${TESTCASES} \
			${disabled_TESTCASES}

TESTCASES_SUBST		= test_subst_syntax test_subst_env \
			test_subst_multiarch

TESTCASES_INSTALL	= test_install_syntax test_install_copy

TESTCASES		= ${TESTCASES_SUBST} ${TESTCASES_INSTALL}

disabled_TESTCASES	= test_combined

TESTS_ENVIRONMENT	= DH_EXEC_LIBDIR="${top_srcdir}/lib" \
			DH_EXEC_BINDIR="${top_srcdir}/src" \
			top_builddir="${top_builddir}" \
			srcdir="${srcdir}"

check: ${TESTS}
	$(AM_V_GEN) ${TESTS_ENVIRONMENT} prove -e '' -f -o $(addprefix ${srcdir}/,${TESTCASES})
