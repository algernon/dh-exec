/* dh-exec-subst.c -- Wrapper around dh-exec-subst-* commands.
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

#include <pipeline.h>

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>
#include <unistd.h>

#include "dh-exec.h"

const char *DH_EXEC_CMD_PREFIX = "dh-exec-subst-";

int
main (int argc, char *argv[])
{
  pipeline *p;
  int status, n;
  struct dirent **cmdlist;

  n = scandir (dh_exec_libdir (), &cmdlist, dh_exec_cmd_filter, alphasort);
  if (n < 0)
    {
      fprintf (stderr, "scandir(\"%s\"): %s\n", dh_exec_libdir(),
               strerror (errno));
      exit (1);
    }

  p = pipeline_new ();
  pipeline_want_infile (p, argv[1]);

  while (n--)
    {
      char *cmd = dh_exec_cmd_path (cmdlist[n]->d_name);
      pipeline_command_args (p, cmd, NULL);
      free (cmd);
    }
  free (cmdlist);

  pipeline_start (p);

  status = pipeline_wait (p);
  pipeline_free (p);

  return status;
}
