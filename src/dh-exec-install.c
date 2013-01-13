/* dh-exec-install.c -- Wrapper around dh-exec-install-magic.
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

#define _GNU_SOURCE

#include <fnmatch.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

#include "dh-exec.lib.h"

const char *DH_EXEC_CMD_PREFIX = "dh-exec-install-";

int
main (int argc, char *argv[])
{
  const char *src = dh_exec_source (argc, 1, argv);

  if (!src)
    {
      fprintf (stderr,
               "%s: Need an input file argument, stdin not acceptable!\n",
               argv[0]);
      exit (1);
    }

  /* Handle cases where the source is not an .install file */
  if (strcmp (src, "install") != 0 &&
      fnmatch ("*[./]install", src, 0) != 0)
    {
      /* Source is stdin, we're piped, ignore it. */
      if (argc < 2)
        return dh_exec_ignore (NULL);
      else
        {
          /* Source is from the command-line directly, raise an
             error. */
          fprintf (stderr,
                   "%s: Only .install filename extensions are allowed: %s\n",
                   argv[0], src);
          exit (1);
        }
    }

  return dh_exec_main (argc, argv);
}
