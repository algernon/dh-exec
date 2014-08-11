/* dh-exec.c -- Wrapper around dh-exec-* commands.
 * Copyright (C) 2011-2014  Gergely Nagy <algernon@debian.org>
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
#include <stdlib.h>
#include <string.h>
#include <getopt.h>
#include <unistd.h>
#include <dirent.h>
#include <errno.h>

#include "dh-exec.lib.h"

const char *DH_EXEC_CMD_PREFIX = "dh-exec-";

#define DH_EXEC_CMD_SEPARATORS ",; \t"

static void
dh_exec_pipeline_add (pipeline *p, const char *cmd)
{
  char *path = dh_exec_cmd_path (dh_exec_libdir (), cmd);
  pipeline_command_args (p, path, NULL);
  free (path);
}

static void
dh_exec_cmdlist_free (char **cmdlist)
{
  int i = 0;

  if (!cmdlist)
    return;

  while (cmdlist[i])
    {
      free (cmdlist[i]);
      i++;
    }
  free (cmdlist);
}

static char **
dh_exec_with (char **cmdlist, const char *prglist)
{
  int i = 0;
  char *t, *orig, *curr;

  orig = strdup (prglist);
  t = orig;
  while (strsep (&t, DH_EXEC_CMD_SEPARATORS))
    i++;
  free (orig);

  orig = strdup (prglist);
  t = orig;

  dh_exec_cmdlist_free (cmdlist);

  cmdlist = (char **)calloc (i + 1, sizeof (char *));
  i = 0;

  while ((curr = strsep (&t, DH_EXEC_CMD_SEPARATORS)) != NULL)
    cmdlist[i++] = strdup (curr);
  free (orig);

  cmdlist[i] = NULL;
  return cmdlist;
}

static char **
dh_exec_without (char **cmdlist, const char *prglist)
{
  char *t, *orig, *prg;

  orig = strdup (prglist);
  t = orig;

  while ((prg = strsep (&t, DH_EXEC_CMD_SEPARATORS)) != NULL)
    {
      int i = 0;

      while (cmdlist[i])
        {
          if (strcmp (cmdlist[i], prg) == 0)
            {
              free (cmdlist[i]);
              cmdlist[i] = strdup ("");
            }
          i++;
        }
    }
  free (orig);

  return cmdlist;
}

static int
dh_exec_help (void)
{
  printf ("dh-exec - Scripts to help with executable debhelper files.\n"
          "\n"
          "Usage: dh-exec [OPTION...] [FILE]\n"
          "\n"
          "  --with=[command,...]        Run with the specified sub-commands only.\n"
          "  --without=[command,...]     Run without the specified sub-commands.\n"
          "  --with-scripts=[script,...] Run with the specified scripts only.\n"
          "  --no-act                    Do not run, just print the pipeline.\n"
          "  --list                      List the available sub-commands and scripts.\n"
          "  --help                      Display this help screen.\n"
          "  --version                   Output version information and exit.\n"
          "\n"
          "When listing helpers, the list needs to be comma separated.\n"
          "\n"
          "For complete documentation, see the dh-exec(1) manual page.\n");
  return EXIT_SUCCESS;
}

static int
dh_exec_version (void)
{
  printf ("dh-exec " PACKAGE_VERSION "\n"
          "\n"
          "Copyright (C) 2011-2013 Gergely Nagy <algernon@debian.org>\n"
          "This is free software; see the source for copying conditions.  There is NO\n"
          "warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.\n"
          "\n"
          "Written by Gergely Nagy <algernon@debian.org>\n");
  return EXIT_SUCCESS;
}

static int
dh_exec_list_filter (const struct dirent *entry)
{
  if (strncmp (entry->d_name, DH_EXEC_CMD_PREFIX,
               strlen (DH_EXEC_CMD_PREFIX)) != 0 ||
      strncmp (entry->d_name + strlen (DH_EXEC_CMD_PREFIX), "strip",
               strlen ("strip")) == 0)
    return 0;
  return 1;
}

static int
dh_exec_list (char *argv[])
{
  struct dirent **cmdlist;
  int n;
  int cplen = strlen (DH_EXEC_CMD_PREFIX);

  printf ("dh-exec - Available sub-commands and scripts\n"
          "\n");

  n = scandir (dh_exec_libdir (), &cmdlist, dh_exec_list_filter, alphasort);
  if (n < 0)
    {
      fprintf (stderr, "%s: scandir(\"%s\"): %s\n", argv[0],
               dh_exec_libdir (), strerror (errno));
      return 1;
    }

  while (n--)
    {
      struct dirent **scriptlist;
      int sn;

      printf (" %s:\n", cmdlist[n]->d_name + cplen);

      sn = scandir (dh_exec_scriptdir (), &scriptlist, dh_exec_list_filter,
                    alphasort);
      if (sn < 0)
        {
          fprintf (stderr, "%s: scandir(\"%s\"): %s\n", argv[0],
                   dh_exec_scriptdir (), strerror (errno));
          free (cmdlist);
          return 1;
        }

      while (sn--)
        {
          if (strncmp (scriptlist[sn]->d_name, cmdlist[n]->d_name,
                       strlen (cmdlist[n]->d_name)) != 0)
            {
              free (scriptlist[sn]);
              continue;
            }

          printf (" \t%s\n", scriptlist[sn]->d_name + cplen);
          free (scriptlist[sn]);
        }

      free (cmdlist[n]);
      free (scriptlist);
    }

  free (cmdlist);

  return 0;
}

int
main (int argc, char *argv[])
{
  pipeline *p;
  int status, n = 0, no_act = 0, do_list = 0;
  const char *src;

  char **dhe_commands, **dhe_scripts = NULL;
  static struct option dhe_options[] = {
    {"with",    required_argument, NULL, 'I'},
    {"with-scripts", required_argument, NULL, 'i'},
    {"without", required_argument, NULL, 'X'},
    {"help",    no_argument      , NULL, 'h'},
    {"version", no_argument      , NULL, 'v'},
    {"no-act",  no_argument      , NULL, 'n'},
    {"list",    no_argument      , NULL, 'l'},
    {NULL,      0                , NULL,  0 },
  };

  dhe_commands = dh_exec_with (NULL, "subst,install");

  while (1)
    {
      int option_index, c;

      c = getopt_long (argc, argv, "hI:i:X:vnl", dhe_options, &option_index);
      if (c == -1)
        break;

      switch (c)
        {
        case 'I':
          dhe_commands = dh_exec_with (dhe_commands, optarg);
          break;
        case 'X':
          dhe_commands = dh_exec_without (dhe_commands, optarg);
          break;
        case 'i':
          dhe_scripts = dh_exec_with (dhe_scripts, optarg);
          break;
        case 'h':
          dh_exec_cmdlist_free (dhe_commands);
          dh_exec_cmdlist_free (dhe_scripts);
          return dh_exec_help ();
        case 'v':
          dh_exec_cmdlist_free (dhe_commands);
          dh_exec_cmdlist_free (dhe_scripts);
          return dh_exec_version ();
        case 'n':
          no_act = 1;
          break;
        case 'l':
          do_list = 1;
          break;
        default:
          dh_exec_help ();
          dh_exec_cmdlist_free (dhe_commands);
          dh_exec_cmdlist_free (dhe_scripts);
          return (EXIT_FAILURE);
        }
    }

  if (do_list)
    {
      dh_exec_cmdlist_free (dhe_commands);
      dh_exec_cmdlist_free (dhe_scripts);
      return dh_exec_list (argv);
    }

  src = dh_exec_source (argc, optind, argv);

  p = pipeline_new ();

  if (src)
    {
      pipeline_want_infile (p, src);
      setenv ("DH_EXEC_SOURCE", src, 1);
    }

  dh_exec_pipeline_add (p, "dh-exec-filter");

  if (dhe_scripts)
    {
      int i = 0;
      int size = 0, pos = 0;
      char *env;

      while (dhe_scripts[i])
        {
          size += strlen (dhe_scripts[i]) + 1;
          i++;
        }

      env = (char *)malloc (size + 1);
      i = 0;

      while (dhe_scripts[i])
        {
          char *path;

          if (asprintf (&path, "%s/dh-exec-%s", dh_exec_scriptdir (),
                        dhe_scripts[i]) <= 0)
            {
              perror ("asprintf");
              exit (1);
            }

          if (access (path, R_OK | X_OK) != 0)
            {
              fprintf (stderr, "%s: script '%s' is not valid!\n", argv[0],
                       dhe_scripts[i]);
              exit (1);
            }
          free (path);

          memcpy (env + pos, dhe_scripts[i], strlen (dhe_scripts[i]));
          pos += strlen (dhe_scripts[i]);
          env[pos++] = '|';
          i++;
        }
      env[pos] = '\0';

      setenv ("DH_EXEC_SCRIPTS", env, 1);

      free (env);
      dh_exec_cmdlist_free (dhe_scripts);
    }

  while (dhe_commands[n])
    {
      char *cmd;

      if (dhe_commands[n][0] == '\0')
        {
          n++;
          continue;
        }

      if (asprintf (&cmd, "%s%s", DH_EXEC_CMD_PREFIX, dhe_commands[n]) <= 0)
        {
          perror ("asprintf");
          exit (EXIT_FAILURE);
        }

      dh_exec_pipeline_add (p, cmd);
      free (cmd);

      n++;
    }

  dh_exec_cmdlist_free (dhe_commands);

  dh_exec_pipeline_add (p, "dh-exec-strip");

  if (no_act)
    {
      pipeline_dump (p, stdout);
      pipeline_free (p);
      return EXIT_SUCCESS;
    }

  pipeline_start (p);
  status = pipeline_wait (p);
  pipeline_free (p);

  return status;
}
