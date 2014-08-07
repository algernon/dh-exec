## -*- shell-script -*-

load "test.lib"

@test "dh-exec-filter: calling with no sub-commands to run still works" {
        run_dh_exec src/dh-exec --no-act --with= <<EOF
#! ${top_builddir}/src/dh-exec
one line


.
EOF
        expect_output "^[^\|]*/dh-exec-filter |" \
                      "[^\|]*/dh-exec-strip \[input: {0, NULL}," \
                      "output: {0, NULL}\]\$"
}

@test "dh-exec-filter: architecture filters work" {
        DEB_HOST_ARCH="hurd-i386" \
                     run_dh_exec_with_input .install <<EOF
#! ${top_builddir}/src/dh-exec-filter
[hurd-i386] this-is-hurd-i386-only
[linux-any] this-is-linux-only
[!kfreebsd-amd64] this-is-not-for-kfreebsd-amd64
[any-i386 any-powerpc] this-is-complicated
EOF
        expect_output "this-is-hurd-i386-only"
        ! expect_output "this-is-linux-only"
        expect_output "this-is-not-for-kfreebsd-amd64"
        expect_output "this-is-complicated"
}

@test "dh-exec-filter: architecture filters catch invalid syntax" {
        DEB_HOST_ARCH="hurd-i386" \
                     run_dh_exec_with_input .install <<EOF
#! ${top_builddir}/src/dh-exec-filter
[any-i386 !powerc] this-is-invalid
EOF
        expect_error "arch filters cannot be mixed"
}

@test "dh-exec-filter: filtered and non-filtered lines work well together" {
        DEB_HOST_ARCH="hurd-i386" \
                     run_dh_exec_with_input .install <<EOF
#! ${top_builddir}/src/dh-exec-filter
[hurd-i386] hurd line to keep
some random line to have, always
[kfreebsd-any] kfreebsd!
and in the end, we have another line.
EOF
        expect_output "hurd line to keep"
        expect_output "some random line to have, always"
        ! expect_output "kfreebsd!"
        expect_output "and in the end, we have another line."
}

@test "dh-exec-filter: postfix filters work too" {
        DEB_HOST_ARCH="hurd-i386" \
                     run_dh_exec_with_input .install <<EOF
#! ${top_builddir}/src/dh-exec-filter
foo [hurd-i386]
bar
EOF
        expect_output "^bar"
}
