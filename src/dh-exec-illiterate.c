/* dh-exec-illiterate.c -- Wrapper around dh-exec-(il)literate-* commands.
 * Copyright (C) 2011  Gergely Nagy <algernon@debian.org>
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

const char *DH_EXEC_CMD_PREFIX = "dh-exec-illiterate-";

int
main (int argc, char *argv[])
{
  return dh_exec_main (argc, argv);
}
