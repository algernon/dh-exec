# -*- sh -*-

set -e

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

