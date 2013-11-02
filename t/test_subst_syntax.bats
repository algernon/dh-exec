## -*- shell-script -*-

load "test.lib"

@test "subst: calling without arguments is valid" {
        run_dh_exec src/dh-exec-subst <<EOF
EOF

        expect_output ""
}

@test "subst: calling as a she-bang works" {
        run_dh_exec_with_input <<EOF
#! ${top_builddir}/src/dh-exec-subst
nothing = ${top_builddir}
EOF

        expect_output "nothing = ${top_builddir}"
}

@test "subst: calling with too many arguments fails" {
        run_dh_exec src/dh-exec-subst too many arguments

        expect_error "no argument at all"
}

@test "subst: calling with a non-existing file fails" {
        run_dh_exec src/dh-exec-subst --invalid-file--

        expect_error "can't open --invalid-file--"
}
