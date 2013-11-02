## -*- shell-script -*-

load "test.lib"

@test "unit: dh_exec_cmd_path() fails if asprintf fails" {
        run t/lib_unit_tests cmd_path

        expect_error "asprintf: Function not implemented"
}

@test "unit: dh_exec_script_allowed() fails if asprintf fails" {
        DH_EXEC_SCRIPTS="" run t/lib_unit_tests script_allowed

        expect_error "asprintf: Function not implemented"
}
