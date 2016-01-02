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

@test "install: renaming manpages gives dh_installmanpages-compatible output" {
        run_dh_exec_with_input .manpages <<EOF
#! ${top_builddir}/src/dh-exec-install
${nullfile} => /var/lib/dh-exec/foo.8
EOF

        expect_file "/var/lib/dh-exec/foo.8"
        ! expect_output " /var/lib/"
}

@test "install: DH_CONFIG_ACT_ON_PACKAGE is honored" {
        DH_CONFIG_ACT_ON_PACKAGES=another-package \
                                 run_dh_exec_with_input package.install <<EOF
#! ${top_builddir}/src/dh-exec-install
${nullfile} => /var/lib/dh-exec/foo.8
EOF
        ! expect_file "/var/lib/dh-exec/foo.8"
        expect_output "/var/lib/dh-exec/foo.8 /var/lib/dh-exec/"
}

@test "install: DH_CONFIG_ACT_ON_PACKAGE works on regexp-y packages too" {
        DH_CONFIG_ACT_ON_PACKAGES=package++ \
                                 run_dh_exec_with_input package++.install <<EOF
#! ${top_builddir}/src/dh-exec-install
${nullfile} => /var/lib/dh-exec/foo.8
EOF
        expect_file "/var/lib/dh-exec/foo.8"
}

@test "install: debian/install works in presence of DH_CONFIG_ACT_ON_PACKAGE" {
        DH_CONFIG_ACT_ON_PACKAGES=package \
                                 run_dh_exec_with_input install <<EOF
#! ${top_builddir}/src/dh-exec-install
${nullfile} => /var/lib/dh-exec/foo.8
EOF
        expect_file "/var/lib/dh-exec/foo.8"
}

@test "install: debian/manpages works in presence of DH_CONFIG_ACT_ON_PACKAGE" {
        DH_CONFIG_ACT_ON_PACKAGES=package \
                                 run_dh_exec_with_input manpages <<EOF
#! ${top_builddir}/src/dh-exec-install
${nullfile} => /var/lib/dh-exec/foo.8
EOF
        expect_file "/var/lib/dh-exec/foo.8"
}

@test "install: DH_CONFIG_ACT_ON_PACKAGE works on packages with dots in their name too" {
    DH_CONFIG_ACT_ON_PACKAGES=libfoo1.0 \
                             run_dh_exec_with_input libfoo1.0.install <<EOF
#! ${top_builddir}/src/dh-exec-install
${nullfile} => /var/lib/dh-exec/foo.8
EOF
    expect_file "/var/lib/dh-exec/foo.8"
}
