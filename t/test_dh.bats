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
