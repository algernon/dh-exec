## -*- shell-script -*-

load "test.lib"

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
                "^[^\|]*/dh-exec-subst | [^\|]*/dh-exec-install |" \
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

        expect_error "subst:"
        ! expect_error "install:"
        expect_error "scandir(.*): No such file or directory"
}
