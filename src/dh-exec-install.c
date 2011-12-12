/* dh-exec-install.c -- Wrapper around dh-exec-install-magic.
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

#define _GNU_SOURCE

#include <fnmatch.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

#include "dh-exec.lib.h"

const char *DH_EXEC_CMD_PREFIX = "dh-exec-install-";

int
main (int argc, char *argv[])
{
  if (argc != 2)
    {
      fprintf (stderr,
               "%s: Need an input file argument, stdin not acceptable!\n",
               argv[0]);
      exit (1);
    }

  if (fnmatch ("*.install", argv[1], 0) != 0)
    {
      fprintf (stderr,
               "%s: Only .install filename extensions are allowed: %s\n",
               argv[0], argv[1]);
      exit (1);
    }

  return dh_exec_main (argc, argv);
}
