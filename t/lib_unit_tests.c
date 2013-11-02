/* lib_unit_tests.c -- Unit tests for dh-exec.lib
 * Copyright (C) 2013  Gergely Nagy <algernon@debian.org>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "dh-exec.lib.h"

#include <errno.h>
#include <stdio.h>
#include <string.h>

int
asprintf(char **strp, ...)
{
  errno = ENOSYS;
  return -1;
}

static int
test_dh_exec_cmd_path (void)
{
  printf ("dh_exec_cmd_path(): %s\n",
          dh_exec_cmd_path ("/some-dir", "file"));

  return 0;
}

static int
test_dh_exec_script_allowed (void)
{
  printf ("dh_exec_script_allowed(): %d\n",
          dh_exec_script_allowed ("dh-exec-script-allowed"));

  return 0;
}

int
main (int argc, char *argv[])
{
  if (argc != 2)
    return 1;

  if (strcmp (argv[1], "cmd_path") == 0)
    return test_dh_exec_cmd_path ();

  if (strcmp (argv[1], "script_allowed") == 0)
    return test_dh_exec_script_allowed ();

  return 1;
}
