# -*- sh -*-

set -e

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

install -d t
cd t

test_lib_cnt=1

tl_plan () {
        echo "1..$1"
}

tl_grep () {
        desc="$1"
        pattern="$2"
        flag=$3
        msg="$4"
        found=0

        if grep -q "${pattern}"; then
                found=1
        else
                found=-1
        fi

        case $(expr ${found} \* ${flag}) in
                1)
                        echo "ok ${test_lib_cnt}"
                        ;;
                -1)
                        echo "not ok ${test_lib_cnt} - ${desc}"
                        echo "#   Failed test in: $0"
                        echo "#   ${msg}: ${pattern}"
                        ;;
        esac
}

tl_expect_match () {
        tl_grep "$1" "$2" 1 "expected"
}

tl_forbid () {
        tl_grep "$1" "$2" -1 "not allowed"
}

tl_expect () {
        tl_expect_match "$1" "^$2\$"
}

alias tl_next='test_lib_cnt=$(expr ${test_lib_cnt} + 1)'
