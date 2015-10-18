## -*- shell-script -*-

load "test.lib"

build_profile_support () {
        perl -MDpkg::BuildProfiles \
             -e 'exit !defined(&Dpkg::BuildProfiles::parse_build_profiles)'
}

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
[any-i386 !powerpc] this-is-invalid
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
        expect_output "^foo"
        expect_output "^bar"
}

@test "dh-exec-filter: arch filters and shell wildcards do mix" {
        DEB_HOST_ARCH="linux-i386" \
                     run_dh_exec_with_input .install <<EOF
#! ${top_builddir}/src/dh-exec-filter
foo [any-i386]
bar[a-z]*
baz[linux]
quux[linux-any]
foobar [i386]
barba[a-z]* [linux-i386]
EOF
        expect_output "^foo"
        expect_output "^bar\[a-z\]\*"
        expect_output "^baz\[linux\]"
        expect_output "^quux\[linux-any\]"
        expect_output "^foobar"
        expect_output "^barba\[a-z\]\*"
}

@test "dh-exec-filter: multiple filters work together" {
        DEB_HOST_ARCH="hurd-i386" \
                     run_dh_exec_with_input .install <<EOF
#! ${top_builddir}/src/dh-exec-filter
[hurd-i386 kfreebsd-any] some-hurd-or-kfreebsd-stuff
EOF
        expect_output "^some-hurd-or-kfreebsd-stuff"
}

@test "dh-exec-filter: multiple stanzas work too" {
        DEB_HOST_ARCH="linux-powerpc" \
                     run_dh_exec_with_input .install <<EOF
#! ${top_builddir}/src/dh-exec-filter
no-armed-powerpc [!linux-armel !linux-powerpc]
rest-of-the-world
EOF
        expect_output "rest-of-the-world"
        ! expect_output "no-armed-powerpc"
}

@test "dh-exec-filter: simple build-profiles work" {
        if ! build_profile_support; then
                skip "Build profiles not supported, libdpkg-perl too old"
        fi

        DEB_BUILD_PROFILES="stage1 stage2" \
                          run_dh_exec_with_input .install <<EOF
#! ${top_builddir}/src/dh-exec-filter
<stage1> stage-1-is-ok
<stage2> stage-2-is-ok
<stage3> stage-3-is-not-enabled
<!cross> non-cross
EOF
        expect_output "^stage-1-is-ok"
        ! expect_output "<stage1>"
        expect_output "^stage-2-is-ok"
        ! expect_output "<stage2>"
        ! expect_output "stage-3"
        ! expect_output "<stage3>"
        expect_output "non-cross"
        ! expect_output "<!cross>"
}

@test "dh-exec-filter: build-profiles OR'd work" {
        if ! build_profile_support; then
                skip "Build profiles not supported, libdpkg-perl too old"
        fi

        DEB_BUILD_PROFILES="stage1 stage2" \
                          run_dh_exec_with_input .install <<EOF
#! ${top_builddir}/src/dh-exec-filter
<stage1> <stage2> <stage3> stage-1-and-2-are-ok
<stage3> <stage4> stage-3-and-4-are-disabled
EOF
        expect_output "stage-1-and-2-are-ok"
        ! expect_output "stage-3-and-4-are-disabled"
}

@test "dh-exec-filter: build-profiles AND'd work" {
        if ! build_profile_support; then
                skip "Build profiles not supported, libdpkg-perl too old"
        fi

        DEB_BUILD_PROFILES="stage1 stage2" \
                          run_dh_exec_with_input .install <<EOF
#! ${top_builddir}/src/dh-exec-filter
<stage1 stage2> stage-1-and-2
<stage1 stage3> stage-1-and-3
EOF
        expect_output "stage-1-and-2"
        ! expect_output "stage-1-and-3"
}

@test "dh-exec-filter: complex build profiles work" {
        if ! build_profile_support; then
                skip "Build profiles not supported, libdpkg-perl too old"
        fi

        DEB_BUILD_PROFILES="stage1 stage2 stage3" \
                          run_dh_exec_with_input .install <<EOF
#! ${top_builddir}/src/dh-exec-filter
<stage1 stage2> <stage2 stage3> <stage4> works!
<stage1 stage4> <stage5> disabled
<stage1 !cross> stage-1-non-cross
EOF
        expect_output "works!"
        expect_output "stage-1-non-cross"
        ! expect_output "disabled"
}

@test "dh-exec-filter: DEB_BUILD_PROFILES without stanzas works" {
        if ! build_profile_support; then
                skip "Build profiles not supported, libdpkg-perl too old"
        fi

        DEB_BUILD_PROFILES="stage1 stage2 stage3" \
                          run_dh_exec_with_input .install <<EOF
#! ${top_builddir}/src/dh-exec-filter
this-should-do
EOF
        expect_output "this-should-do"
}

@test "dh-exec-filter: Build Profiles hanles the normal build case" {
        if ! build_profile_support; then
                skip "Build profiles not supported, libdpkg-perl too old"
        fi

        DEB_BUILD_PROFILES="" \
                          run_dh_exec_with_input .install <<EOF
#! ${top_builddir}/src/dh-exec-filter
<stage1> only-stage-1
<!stage1> not-stage-1
EOF
        expect_output "not-stage-1"
        ! expect_output "only-stage-1"
}
