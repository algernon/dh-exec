# -*- sh -*-

test_lib_cnt=1

tl_plan () {
        echo "1..$1"
}

tl_expect_match () {
        desc="$1"
        expect="$2"

        if grep -q "${expect}"; then
                echo "ok ${test_lib_cnt}"
        else
                echo "not ok ${test_lib_cnt} - ${desc}"
                echo "#   Failed test in : $0"
                echo "#          expected: ${expect}"
        fi
}

tl_expect () {
        tl_expect_match "$1" "^$2\$"
}

alias tl_next='test_lib_cnt=$(expr ${test_lib_cnt} + 1)'

