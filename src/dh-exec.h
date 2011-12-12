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

#ifndef DH_EXEC_H
#define DH_EXEC_H

#include <dirent.h>

extern const char *DH_EXEC_CMD_PREFIX;

const char *dh_exec_libdir (void);
char *dh_exec_cmd_path (const char *cmd);
int dh_exec_cmd_filter (const struct dirent *entry);
int dh_exec_main (int argc, char *argv[]);

#endif
