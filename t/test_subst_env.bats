## -*- shell-script -*-

load "test.lib"

setup () {
        dh_subst_test_empty_var=""
        dh_subst_test_var="foo"

        unset dh_subst_test_novar
        export dh_subst_test_var
        export dh_subst_test_empty_var
}

run_dh_exec_subst () {
        run_dh_exec src/dh-exec-subst <<EOF
dh_subst_test_var   = \${dh_subst_test_var}
dh_subst_test_novar = \${dh_subst_test_novar}
dh_subst_test_empty_var = \${dh_subst_test_empty_var}
EOF
}

@test "subst-env: defined variable gets expanded" {
        run_dh_exec_subst

        expect_output 'dh_subst_test_var   = foo'
}

@test "subst-env: undefined variable is not expanded" {
        run_dh_exec_subst

        expect_output 'dh_subst_test_novar = ${dh_subst_test_novar}'
}

@test "subst-env: defined but empty variable gets expanded" {
        run_dh_exec_subst

        expect_output 'dh_subst_test_empty_var = '
}
