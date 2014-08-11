/* dh-exec.simple.c -- Simple wrapper around dh-exec-* commands.
 * Copyright (C) 2011, 2013  Gergely Nagy <algernon@debian.org>
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

#include "config.h"

#include "dh-exec.lib.h"

#ifndef dh_exec_simple_preamble
#define dh_exec_simple_preamble(argc,argv) 0
#endif

int
main (int argc, char *argv[])
{
  int r;

  if ((r = dh_exec_simple_preamble (argc, argv)) != 0)
    return r;

  return dh_exec_main ("dh-exec-" DH_EXEC_CMD "-", argc, argv);
}
