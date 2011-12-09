/* dh_subst.c -- Wrapper around dh_subst_ commands.
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

#define DH_SUBST_LIBDIR "/usr/lib/dh-subst"
#define DH_CMD_PREFIX "dh_subst_"

const char *
dh_subst_libdir (void)
{
  char *e;

  e = getenv ("DH_SUBST_LIBDIR");
  if (e)
    return e;
  return DH_SUBST_LIBDIR;
}

char *
dh_subst_cmd (const char *cmd)
{
  char *path;

  if (asprintf (&path, "%s/%s", dh_subst_libdir (), cmd) <= 0)
    {
      perror ("asprintf");
      exit (1);
    }

  return path;
}

int
dh_subst_cmd_filter (const struct dirent *entry)
{
  char *path;
  int r;

  if (strncmp (entry->d_name, DH_CMD_PREFIX, strlen (DH_CMD_PREFIX)) != 0)
    return 0;

  path = dh_subst_cmd (entry->d_name);
  r = access (path, X_OK);
  free (path);

  return !r;
}

int
main (int argc, char *argv[])
{
  pipeline *p;
  int status, n;
  struct dirent **cmdlist;

  n = scandir (dh_subst_libdir (), &cmdlist, dh_subst_cmd_filter, alphasort);
  if (n < 0)
    {
      fprintf (stderr, "scandir(\"%s\"): %s\n", dh_subst_libdir(),
               strerror (errno));
      exit (1);
    }

  p = pipeline_new ();
  pipeline_want_infile (p, argv[1]);

  while (n--)
    {
      char *cmd = dh_subst_cmd (cmdlist[n]->d_name);
      pipeline_command_args (p, cmd, NULL);
      free (cmd);
    }
  free (cmdlist);

  pipeline_start (p);

  status = pipeline_wait (p);
  pipeline_free (p);

  return status;
}
