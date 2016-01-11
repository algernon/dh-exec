## -*- shell-script -*-

load "test.lib"

setup () {
        td=$(mktemp -d --tmpdir=.)
        cd "${td}"
}

teardown () {
    cd ..
    rm -rf "${td}"
}

@test "install: moving works" {
    install -d var/lib/dh-exec
    echo foo >var/lib/dh-exec/test-output

    run_dh_exec_with_input .install <<EOF
#! ${top_builddir}/src/dh-exec-install
=> var/lib/dh-exec/test-output
EOF

    expect_file "/var/lib/dh-exec/test-output"
    ! [ -f var/lib/dh-exec/test-output ]
}

@test "install: rename takes priority over move" {
    install -d var/lib/dh-exec
    echo foo >var/lib/dh-exec/test-output

    run_dh_exec_with_input .install <<EOF
#! ${top_builddir}/src/dh-exec-install
var/lib/dh-exec/test-output => var/lib/dh-exec/test-output
EOF

    expect_file "/var/lib/dh-exec/test-output"
    [ -f var/lib/dh-exec/test-output ]
}

@test "install: move can override rename on request" {
    install -d var/lib/dh-exec
    echo foo >var/lib/dh-exec/test-output

    run_dh_exec_with_input .install <<EOF
#! ${top_builddir}/src/dh-exec --with-scripts=install-move
var/lib/dh-exec/test-output => var/lib/dh-exec/test-output
EOF

    expect_file "/var/lib/dh-exec/test-output"
    ! [ -f var/lib/dh-exec/test-output ]
}
