## -*- shell-script -*-

load "test.lib"

setup () {
        td=$(mktemp -d --tmpdir=. tmpXXXXXXXX)
        cd "${td}"
        install -d debian/tmp

        pkgdir=$(mktemp -d --tmpdir=debian pkg-dh-exec-XXXXXX)
        pkgfile="${pkgdir}.install"

        install -d "${pkgdir}/var/lib/dh-exec"
        install -d "${pkgdir}/usr/lib/dh-exec/$(dpkg-architecture -qDEB_HOST_MULTIARCH)"

        cat >${pkgfile} <<EOF
#! ${DH_EXEC_BINDIR}/dh-exec
${pkgfile} /var/lib/dh-exec/
${pkgfile} => /var/lib/dh-exec/new-file
${pkgfile} /usr/lib/dh-exec/\${DEB_HOST_MULTIARCH}/
${pkgfile} => /usr/lib/dh-exec/\${DEB_HOST_MULTIARCH}/new-file
[!hurd-i386] ${pkgfile} => /var/lib/dh-exec/not-hurd
EOF

        chmod +x ${pkgfile}
}

teardown () {
        cd ..
        rm -rf "${td}"
}

@test "combined: Copying to dir gets passed on, no expansions" {
        run_dh_exec ${td}/${pkgfile}
        expect_output "${pkgfile} /var/lib/dh-exec/"
}

@test "combined: copying a file with a rename gets acted upon" {
        run_dh_exec ${td}/${pkgfile}
        expect_file "/var/lib/dh-exec/new-file"
}

@test "combined: multi-arch variable gets expanded, and copied" {
        run_dh_exec ${td}/${pkgfile}
        expect_output "${pkgfile} /usr/lib/dh-exec/$(dpkg-architecture -qDEB_HOST_MULTIARCH)/"
}

@test "combined: multi-arch variables get expanded before copying" {
        run_dh_exec ${td}/${pkgfile}
        expect_file "/usr/lib/dh-exec/$(dpkg-architecture -qDEB_HOST_MULTIARCH)/new-file"
}

@test "combined: dh-exec --without works" {
        run_dh_exec_with_input .install <<EOF
#! ${DH_EXEC_BINDIR}/dh-exec --without=subst
${pkgfile} /usr/lib/dh-exec/\${DEB_HOST_MULTIARCH}
EOF
        expect_output "\${DEB_HOST_MULTIARCH}"
}

@test "combined: dh-exec --with works" {
        run_dh_exec_with_input .install <<EOF
#! ${DH_EXEC_BINDIR}/dh-exec --with=install
${pkgfile} /usr/lib/dh-exec/\${DEB_HOST_MULTIARCH}
EOF
        expect_output "\${DEB_HOST_MULTIARCH}"
}

@test "combined: dh-exec --with with everything excluded works" {
        run_dh_exec_with_input .install <<EOF
#! ${DH_EXEC_BINDIR}/dh-exec --without=subst,install
${pkgfile} /usr/lib/dh-exec/\${DEB_HOST_MULTIARCH}
EOF
        expect_output "\${DEB_HOST_MULTIARCH}"
}

@test "combined: dh-exec --with a program list works" {
        run_dh_exec_with_input .install <<EOF
#! ${DH_EXEC_BINDIR}/dh-exec --with=subst,install
${pkgfile} /usr/lib/dh-exec/\${DEB_HOST_MULTIARCH}
EOF
        expect_output "$(dpkg-architecture -qDEB_HOST_MULTIARCH)"
}

@test "combined: dh-exec --with-scripts works" {
        export dh_subst_test_var=1
        run_dh_exec_with_input .install <<EOF
#! ${DH_EXEC_BINDIR}/dh-exec --with-scripts=subst-multiarch
${pkgfile} /usr/lib/dh-exec/\${DEB_HOST_MULTIARCH}/\${dh_subst_test_var}
EOF
        expect_output "$(dpkg-architecture -qDEB_HOST_MULTIARCH)/\${dh_subst_test_var}"
}

@test "combined: dh-exec arch filters with install work" {
        DEB_HOST_ARCH=hurd-i386 run_dh_exec ${td}/${pkgfile}
        ! expect_file "/var/lib/dh-exec/not-hurd"
}
