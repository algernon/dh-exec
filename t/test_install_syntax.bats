## -*- shell-script -*-

load "test.lib"

@test "install: calling without arguments is invalid" {
        run_dh_exec src/dh-exec-install
        expect_error "stdin not acceptable"
}

setup () {
        nullfile=$(mktemp --tmpdir=.)
        touch ${nullfile}
}

teardown () {
        rm -rf "${nullfile}"
        rm -rf debian/
}

@test "install: Calling as a she-bang works" {
        run_dh_exec_with_input .install <<EOF
#! ${top_builddir}/src/dh-exec-install
${nullfile} => /var/lib/dh-exec/test-output
foo/bar /tmp/foo
baz/quux
# This is an empty line:


EOF
        expect_output "debian/tmp/dh-exec\."
}

@test "install: trailing whitespace gets correctly stripped" {
        run_dh_exec_with_input .install <<EOF
#! ${top_builddir}/src/dh-exec-install
${nullfile}   =>   /var/lib/dh-exec/test-output-2  
EOF

        expect_output "debian/tmp/dh-exec\..*/var/lib/dh-exec/test-output-2 /var/lib/dh-exec/$"
}

@test "install: calling with an unqualified debian/install works" {
        run_dh_exec src/dh-exec-install debian/install

        expect_error "No such file or directory"
}

@test "install: calling with a manpages file works" {
        run_dh_exec src/dh-exec-install debian/manpages

        expect_error "No such file or directory"
}

@test "install: calling with an unqualified install works" {
        run_dh_exec src/dh-exec-install install

        expect_error "No such file or directory"
}

@test "install: using an invalid filename fails, even if the file exists" {
        run_dh_exec_with_input .invalid <<EOF
#! ${top_builddir}/src/dh-exec-install
EOF

        expect_error "Unsupported filename extension"
}

@test "install: calling with too many arguments fails" {
        run_dh_exec src/dh-exec-install too.install many.install arguments.install

        expect_error "no argument at all"
}

@test "install: calling with a non-existing file does not work" {
        run_dh_exec src/dh-exec-install --invalid-file--.install

        expect_error "can't open --invalid-file--"
}

@test "install: piping passes through unchanged" {
        DH_EXEC_SOURCE="some-file" run_dh_exec src/dh-exec-install <<EOF
${nullfile}   =>   /var/lib/dh-exec/test-output-2
EOF

        expect_output "=>"
}
