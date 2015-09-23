## -*- shell-script -*-

load "test.lib"

run_dh_exec_dh_tests () {
        arch=${1:+-a$1}

        case $(dpkg-query -f '${Version}' --show debhelper) in
                9*)
                        ;;
                *)
                        skip "debhelper is too old"
                        ;;
        esac

        ln -sf ${BINDIR}/dh-exec .

        DEB_HOST_MULTIARCH=$(dpkg-architecture ${arch} -f -qDEB_HOST_MULTIARCH 2>/dev/null)

        PATH=${BINDIR}:${PATH} \
                dpkg-buildpackage -us -uc -b -d ${arch} 2>/dev/null
        debian/rules clean
        rm -f dh-exec

        run dpkg-deb -c ../pkg-test_0_all.deb
        expect_output "./usr/bin/bin-foo"

        run dpkg-deb -c ../pkg-test_0_all.deb
        expect_output "./usr/bin/bin-arch"

        run dpkg-deb -c ../pkg-test_0_all.deb
        expect_output "./usr/lib/pkg-test/${DEB_HOST_MULTIARCH}/plugin-multiarch"

        run dpkg-deb -c ../pkg-test_0_all.deb
        expect_output "./usr/lib/pkg-test/${DEB_HOST_MULTIARCH}/another-plugin\$"

        run dpkg-deb -c ../pkg-test-illiterate_0_all.deb
        expect_output "./usr/bin/bin-foo"

        run dpkg-deb -c ../pkg-test-illiterate_0_all.deb
        expect_output "./usr/bin/bin-arch"

        run dpkg-deb -c ../pkg-test-illiterate_0_all.deb
        expect_output "./usr/lib/pkg-test/${DEB_HOST_MULTIARCH}/plugin-multiarch"

        run dpkg-deb -c ../pkg-test-illiterate_0_all.deb
        expect_output "./usr/lib/pkg-test/${DEB_HOST_MULTIARCH}/another-plugin\$"
}

setup () {
        td=$(mktemp -d --tmpdir=$(pwd) tmpXXXXXX)
        tar -C ${SRCDIR} -c pkg-test | tar -C ${td} -x

        chmod -R ugo+rX,u+w ${td}
        cd ${td}/pkg-test

        unset MAKEFLAGS MFLAGS
}

teardown () {
        cd ../..
        rm -rf ${td}
}

@test "dh: running on the native architecture" {
        run_dh_exec_dh_tests
}

@test "dh: linux-powerpc cross-build" {
        run_dh_exec_dh_tests linux-powerpc
}

@test "dh: kfreebsd-i386 cross-build" {
        run_dh_exec_dh_tests kfreebsd-i386
}

@test "dh: Noop when package not built" {
        case $(dpkg-query -f '${Version}' --show debhelper) in
                9*)
                        ;;
                *)
                        skip "debhelper is too old"
                        ;;
        esac

        if ! grep -q "DH_CONFIG_ACT_ON_PACKAGES" /usr/share/perl5/Debian/Debhelper/Dh_Lib.pm; then
                skip "debhelper does not support DH_CONFIG_ACT_ON_PACKAGES"
        fi

        ln -sf ${BINDIR}/dh-exec .

        DEB_HOST_MULTIARCH=$(dpkg-architecture ${arch} -f -qDEB_HOST_MULTIARCH 2>/dev/null)

        PATH=${BINDIR}:${PATH} \
                dpkg-buildpackage -us -uc -b -d ${arch} 2>/dev/null
        debian/rules clean
        rm -f dh-exec

        run dpkg-deb -c ../pkg-test-no-install_0_all.deb >/tmp/blah
        expect_output "./usr/share/doc/pkg-test-no-install/copyright\$"
        ! expect_output "./usr/bin/not-going-to-happen"
}
