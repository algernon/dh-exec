/* dh-exec-install.c -- Wrapper around dh-exec-install-magic.
 * Copyright (C) 2011, 2013, 2014  Gergely Nagy <algernon@debian.org>
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

#include <fnmatch.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

#include "dh-exec.lib.h"

static int
_match_extension (const char *src, const char *ext)
{
  char *glob;

  glob = malloc (strlen (ext) + 6);
  memcpy (glob, "*[./]", 5);
  memcpy (glob + 5, ext, strlen (ext) + 1);

  if (strcmp (src, ext) != 0 &&
      fnmatch (glob, src, 0) != 0)
    return 0;

  return 1;
}

static int
preamble(int argc, char *argv[])
{
  const char *src = dh_exec_source (argc, 1, argv);

  if (!src)
    {
      fprintf (stderr,
               "%s: Need an input file argument, stdin not acceptable!\n",
               argv[0]);
      return EXIT_FAILURE;
    }

  /* Handle cases where the source is not an .install file */
  if (!_match_extension (src, "install") &&
      !_match_extension (src, "manpages"))
    {
      /* Source is stdin, we're piped, ignore it. */
      if (argc < 2)
        return (dh_exec_ignore ());
      else
        {
          /* Source is from the command-line directly, raise an
             error. */
          fprintf (stderr,
                   "%s: Unsupported filename extension: %s\n",
                   argv[0], src);
          return EXIT_FAILURE;
        }
    }

  return 0;
}

#define dh_exec_simple_preamble preamble

#include "dh-exec.simple.c"
