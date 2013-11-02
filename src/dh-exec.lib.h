/* dh-exec.lib.h -- Wrapper around dh-exec-* commands.
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

#ifndef DH_EXEC_LIB_H
#define DH_EXEC_LIB_H

#include <dirent.h>

const char *dh_exec_scriptdir (void);
const char *dh_exec_libdir (void);
const char *dh_exec_source (int argc, int optind, char *argv[]);

char *dh_exec_cmd_path (const char *dir, const char *cmd);
int dh_exec_cmd_filter (const struct dirent *entry);
int dh_exec_main (const char *cmd_prefix, int argc, char *argv[]);
int dh_exec_ignore (void);

#endif
