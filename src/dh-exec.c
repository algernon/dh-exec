/* dh-exec.c -- Wrapper around dh-exec-* commands.
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

#include "dh-exec.lib.h"

const char *DH_EXEC_CMD_PREFIX = "dh-exec-";

static void
dh_exec_pipeline_add (pipeline *p, const char *cmd, const char *src)
{
  char *path = dh_exec_cmd_path (dh_exec_bindir (), cmd);
  pipeline_command_args (p, path, src, NULL);
  free (path);
}

int
main (int argc, char *argv[])
{
  pipeline *p;
  int status;
  char *src = NULL, *cmd;

  if (argc >= 2)
    src = argv[1];

  p = pipeline_new ();
  dh_exec_pipeline_add (p, "dh-exec-install", src);
  dh_exec_pipeline_add (p, "dh-exec-subst", NULL);

  pipeline_start (p);
  status = pipeline_wait (p);
  pipeline_free (p);

  return status;
}
