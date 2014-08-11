/* dh-exec.lib.c -- Wrapper around dh-exec-* commands.
 * Copyright (C) 2011-2013  Gergely Nagy <algernon@debian.org>
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

#include "config.h"

#include <pipeline.h>

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>
#include <unistd.h>

#include "dh-exec.lib.h"

#define DH_EXEC_SCRIPTDIR "/usr/share/dh-exec"
#define DH_EXEC_LIBDIR "/usr/lib/dh-exec"

#ifndef DH_EXEC_CMD_ALWAYS
#define DH_EXEC_CMD_ALWAYS 0
#endif

static const char *DH_EXEC_CMD_PREFIX;

const char *
dh_exec_scriptdir (void)
{
  char *e;

  e = getenv ("DH_EXEC_SCRIPTDIR");
  if (e)
    return e;
  return DH_EXEC_SCRIPTDIR;
}

const char *
dh_exec_libdir (void)
{
  char *e;

  e = getenv ("DH_EXEC_LIBDIR");
  if (e)
    return e;
  return DH_EXEC_LIBDIR;
}

const char *
dh_exec_source (int argc, int optind, char *argv[])
{
  if (argc - optind >= 1)
    return argv[optind];
  return getenv ("DH_EXEC_SOURCE");
}

char *
dh_exec_cmd_path (const char *dir, const char *cmd)
{
  char *path;

  if (asprintf (&path, "%s/%s", dir, cmd) <= 0)
    {
      perror ("asprintf");
      exit (1);
    }

  return path;
}

static int
dh_exec_script_allowed (const char *fn)
{
  char *e;
  char *needle;

  if (DH_EXEC_CMD_ALWAYS)
    return 0;

  e = getenv ("DH_EXEC_SCRIPTS");
  if (!e)
    return 0;

  if (asprintf (&needle, "%s|", fn + strlen ("dh-exec-")) <= 0)
    {
      perror ("asprintf");
      exit (1);
    }

  if (strstr (e, needle) == NULL)
    {
      free (needle);
      return 1;
    }

  free (needle);
  return 0;
}

int
dh_exec_cmd_filter (const struct dirent *entry)
{
  char *path;
  int r;

  if (strncmp (entry->d_name, DH_EXEC_CMD_PREFIX,
               strlen (DH_EXEC_CMD_PREFIX)) != 0)
    return 0;
  if (dh_exec_script_allowed (entry->d_name) != 0)
    return 0;

  path = dh_exec_cmd_path (dh_exec_scriptdir (), entry->d_name);
  r = access (path, X_OK);
  free (path);

  return !r;
}

int
dh_exec_main (const char *cmd_prefix, int argc, char *argv[])
{
  pipeline *p;
  int status, n;
  struct dirent **cmdlist;

  if (argc > 2)
    {
      fprintf (stderr,
               "%s: Need an input file argument, or no argument at all!\n",
               argv[0]);
      exit (1);
    }

  DH_EXEC_CMD_PREFIX = cmd_prefix;

  n = scandir (dh_exec_scriptdir (), &cmdlist, dh_exec_cmd_filter, alphasort);
  if (n < 0)
    {
      fprintf (stderr, "%s: scandir(\"%s\"): %s\n", argv[0],
               dh_exec_scriptdir(), strerror (errno));
      exit (1);
    }

  p = pipeline_new ();
  if (argc == 2)
    {
      setenv ("DH_EXEC_SOURCE", argv[1], 1);
      pipeline_want_infile (p, argv[1]);
    }

  while (n--)
    {
      char *cmd = dh_exec_cmd_path (dh_exec_scriptdir (), cmdlist[n]->d_name);
      pipeline_command_args (p, cmd, NULL);
      free (cmd);
      free (cmdlist[n]);
    }
  free (cmdlist);

  if (pipeline_get_ncommands (p) == 0)
    pipeline_command_args (p, "cat", NULL);

  pipeline_start (p);

  status = pipeline_wait (p);
  pipeline_free (p);

  return status;
}

int
dh_exec_ignore (void)
{
  pipeline *p;
  int status;

  p = pipeline_new ();
  pipeline_command_args (p, "cat", NULL);

  pipeline_start (p);
  status = pipeline_wait (p);
  pipeline_free (p);

  return status;
}
