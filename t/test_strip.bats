## -*- shell-script -*-

load "test.lib"

@test "dh-exec-strip: the she-bang gets removed from the output" {
        run_dh_exec src/dh-exec --without=install <<EOF
#! ${top_builddir}/src/dh-exec
# This is another comment.
we add some stuff, such as \${DH_EXEC_SOURCE}

# and some more comments
and in the end, we quit
EOF
        expect_output "some stuff"
        ! expect_output "#"
}

@test "dh-exec-strip: empty lines get removed from the output" {
        run_dh_exec src/dh-exec --without=install <<EOF
#! ${top_builddir}/src/dh-exec
## This is another comment.
some LINES

and the final one
EOF
        expect_output "some LINES"
        ! expect_output "^$"
}

@test "dh-exec-strip: whitespace-only lines get removed" {
        run_dh_exec src/dh-exec --without=install <<EOF
#! ${top_builddir}/src/dh-exec
## This is another comment.
some LINES
   	   
and the final one
EOF
        expect_output "some LINES"
        ! expect_output "^[ 	]\{1,\}$"
}

@test "dh-exec-strip: calling with no sub-commands to run still works" {
        run_dh_exec src/dh-exec --no-act --with= <<EOF
#! ${top_builddir}/src/dh-exec
one line


.
EOF
        expect_output "^[^\|]*/dh-exec-strip \[input: {0, NULL}," \
                      "output: {0, NULL}\]\$"
}

@test "dh-exec-strip: calling with --with-scripts still strips" {
        run_dh_exec_with_input .install <<EOF
#! ${top_builddir}/src/dh-exec --with-scripts=subst-multiarch
something...
EOF
        expect_output "something"
        ! expect_output "#"
}

@test "dh-exec-strip: architecture filters work" {
        DEB_HOST_ARCH="hurd-i386" \
                     run_dh_exec_with_input .install <<EOF
#! ${top_builddir}/src/dh-exec-strip
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

@test "dh-exec-strip: architecture filters catch invalid syntax" {
        DEB_HOST_ARCH="hurd-i386" \
                     run_dh_exec_with_input .install <<EOF
#! ${top_builddir}/src/dh-exec-strip
[any-i386 !powerc] this-is-invalid
EOF
        expect_error "arch filters cannot be mixed"
}
