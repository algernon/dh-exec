# -*- sh -*-

test_lib_cnt=1

tl_plan () {
        echo "1..$1"
}

tl_expect () {
        desc="$1"
        expect="$2"

        if grep -q "^${expect}$"; then
                echo "ok ${test_lib_cnt}"
        else
                echo "not ok ${test_lib_cnt} - ${desc}"
                echo "#   Failed test in : $0"
                echo "#          expected: ${expect}"
        fi
}

alias tl_next='test_lib_cnt=$(expr ${test_lib_cnt} + 1)'

