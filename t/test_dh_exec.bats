## -*- shell-script -*-

load "test.lib"

setup () {
        test_tmpdir=$(mktemp -d --tmpdir=.)
}

teardown () {
        rm -rf "${test_tmpdir}"
}

@test "calling dh-exec --help works" {
        run_dh_exec src/dh-exec --help
        expect_output "Scripts to help with executable debhelper files"
}

@test "calling dh-exec --version works" {
        run_dh_exec src/dh-exec --version
        expect_output "This is free software"
}

@test "dh-exec --no-act works" {
        run_dh_exec src/dh-exec --no-act random.install
        expect_output \
                "^[^\|]*/dh-exec-filter | [^\|]*/dh-exec-subst |" \
                "[^\|]*/dh-exec-install |" \
                "[^\|]*/dh-exec-strip \[input: {0, random.install}," \
                "output: {0, NULL}\]\$"
}

@test "dh-exec --list works" {
        run_dh_exec src/dh-exec --list
        expect_output "	illiterate-tangle"
}

@test "dh-exec --list skips dh-exec-strip" {
        run_dh_exec src/dh-exec --list
        ! expect_output "strip"
}

@test "dh-exec: calling with invalid DH_EXEC_LIBDIR fails gracefully" {
        DH_EXEC_LIBDIR=$(pwd)/non-existent run_dh_exec src/dh-exec --list

        ! expect_error "subst:"
        expect_error "scandir(.*): No such file or directory"
}

@test "dh-exec: calling with invalid DH_EXEC_SCRIPTDIR fails gracefully" {
        DH_EXEC_SCRIPTDIR=$(pwd)/non-existent run_dh_exec src/dh-exec --list

        expect_error "subst.*:"
        ! expect_error "install.*:"
        expect_error "scandir(.*): No such file or directory"
}

@test "dh-exec: An invalid option produces an error" {
        run_dh_exec src/dh-exec --invalid-option

        expect_error "unrecognized option '--invalid-option'"
}

@test "dh-exec: Non-executable scripts produce an error" {
        touch "${test_tmpdir}/dh-exec-subst-foo"

        DH_EXEC_SCRIPTDIR="${test_tmpdir}" run_dh_exec src/dh-exec --with-scripts=subst-foo
        expect_error "script 'subst-foo' is not valid"
}

@test "dh-exec: Non-existing scripts produce an error" {
        run_dh_exec src/dh-exec --with-scripts=subst-something-else

        expect_error "script 'subst-something-else' is not valid"
}

@test "dh-exec: non-existing helper produces an error" {
        run_dh_exec src/dh-exec --with=something </dev/null

        expect_error "can't execute .*/dh-exec-something"
}

@test "dh-exec: running bare works" {
        unset DH_EXEC_SCRIPTDIR
        unset DH_EXEC_LIBDIR

        run_dh_exec src/dh-exec --list

        expect_anything "dh-exec - Available sub-commands and scripts"
}

@test "dh-exec-subst: Running with an empty scriptdir fails" {
        DH_EXEC_SCRIPTDIR=$(pwd)/non-existent run_dh_exec src/dh-exec-subst <<EOF
${HOME}
EOF

        expect_error "scandir(.*): No such file or directory"
}
