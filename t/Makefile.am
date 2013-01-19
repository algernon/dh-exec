EXTRA_DIST		= test.lib.sh ${TESTCASES} \
			${disabled_TESTCASES}

TESTCASES_SUBST		= test_subst_syntax test_subst_env \
			test_subst_multiarch
TESTCASES_INSTALL	= test_install_syntax test_install_copy
TESTCASES_ILLITERATE	= test_illiterate
TESTCASES_DH		= test_dh
TESTCASES_MISC		= test_combined test_help

TESTCASES		= ${TESTCASES_SUBST} ${TESTCASES_INSTALL} \
			${TESTCASES_MISC} ${TESTCASES_DH} \
			${TESTCASES_ILLITERATE}

TESTS_ENVIRONMENT	= DH_EXEC_SCRIPTDIR="${top_srcdir}/lib" \
			DH_EXEC_LIBDIR="${top_builddir}/src" \
			DH_EXEC_BINDIR="${top_builddir}/src" \
			top_builddir="${top_builddir}" \
			srcdir="${srcdir}" \
			NO_PKG_MANGLE=1

check: ${TESTS}
	$(AM_V_GEN) ${TESTS_ENVIRONMENT} prove -e '' -f -o ${PROVE_OPTIONS} $(addprefix ${srcdir}/,${TESTCASES})
