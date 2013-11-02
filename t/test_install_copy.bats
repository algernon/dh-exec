## -*- shell-script -*-

load "test.lib"

setup () {
        td=$(mktemp -d --tmpdir=.)
        cd "${td}"

        nullfile=$(mktemp --tmpdir=.)
        touch ${nullfile}
}

teardown () {
        cd ..
        rm -rf "${td}"
}

@test "install: copying works" {
        run_dh_exec_with_input .install <<EOF
#! ${top_builddir}/src/dh-exec-install
${nullfile} => /var/lib/dh-exec/test-output
EOF

        expect_file "/var/lib/dh-exec/test-output"
}

@test "install: copying from debian/tmp works" {
        install -d debian/tmp
        touch debian/tmp/foo.test

        run_dh_exec_with_input .install <<EOF
#! ${top_builddir}/src/dh-exec-install
foo.test => /var/lib/dh-exec/test-output.foo
EOF

        expect_file "/var/lib/dh-exec/test-output.foo"
}

@test "install: renaming preserves permissions" {
        chmod +x "${nullfile}"

        run_dh_exec_with_input .install <<EOF
#! ${top_builddir}/src/dh-exec-install
${nullfile} => /var/lib/dh-exec/test-executable
EOF

        expect_file -x "/var/lib/dh-exec/test-executable"
}
