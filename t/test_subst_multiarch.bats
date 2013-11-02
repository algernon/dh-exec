## -*- shell-script -*-

load "test.lib"

setup () {
        DEB_HOST_ARCH_BITS=128

        export DEB_HOST_ARCH_BITS
}

run_dh_exec_subst () {
        run_dh_exec src/dh-exec-subst <<EOF
DEB_HOST_MULTIARCH = \${DEB_HOST_MULTIARCH}
DEB_HOST_ARCH_BITS = \${DEB_HOST_ARCH_BITS}
EOF
}

@test "subst-multiarch: multi-arch variable is set" {
        run_dh_exec_subst

        expect_output "DEB_HOST_MULTIARCH = $(dpkg-architecture -qDEB_HOST_MULTIARCH)"
}

@test "subst-multiarch: ARCH_BITS uses environment variable" {
        run_dh_exec_subst

        expect_output "DEB_HOST_ARCH_BITS = 128"
}

@test "subst-multiarch: ARCH_BITS falls back to dpkg-architecture" {
        unset DEB_HOST_ARCH_BITS

        run_dh_exec_subst

        expect_output "DEB_HOST_ARCH_BITS = $(dpkg-architecture -qDEB_HOST_ARCH_BITS)"
}
