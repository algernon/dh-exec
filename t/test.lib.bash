## -*- shell-script -*-

cd ${srcdir}
SRCDIR=$(pwd)
cd - >/dev/null

cd ${DH_EXEC_BINDIR}
BINDIR=$(pwd)
cd - >/dev/null

cd ${DH_EXEC_SCRIPTDIR}
SCRIPTDIR=$(pwd)
cd - >/dev/null

cd ${DH_EXEC_LIBDIR}
LIBDIR=$(pwd)
cd - >/dev/null

cd ${top_builddir}
top_builddir=$(pwd)
cd - >/dev/null

export top_builddir
export DH_EXEC_BINDIR="${BINDIR}"
export DH_EXEC_SCRIPTDIR="${SCRIPTDIR}"
export DH_EXEC_LIBDIR="${LIBDIR}"

run_dh_exec () {
        script=$1
        shift

        run ${top_builddir}/${script} $@
}

run_dh_exec_with_input () {
        t=$(mktemp --tmpdir=. tmpXXXXXXXX${1})
        cat >"${t}"
        chmod +x "${t}"
        run "${t}"
        rm -f "${t}"
}

expect_anything () {
        echo "${output}" | grep -q "$(echo $@)"
}

expect_output () {
        [ "$status" -eq 0 ]
        expect_anything "$@"
}

expect_error () {
        [ "$status" -ne 0 ]
        expect_anything "$@"
}

expect_file () {
        if [ $# -eq 1 ]; then
                file=$1
                check="-f"
        else
                check=$1
                file=$2
        fi
        dtmpdir=$(echo "$output" | sed -n 's#\(debian/tmp/dh-exec\.[^/]*\).*#\1#gp' | sort -u)

        [ $check "${dtmpdir}${file}" ]
}
