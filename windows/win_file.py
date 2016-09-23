#!/usr/bin/python
# -*- coding: utf-8 -*-

# (c) 2015, Jon Hawkesworth (@jhawkesworth) <figs@unity.demon.co.uk>
#
# This file is part of Ansible
#
# Ansible is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Ansible is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Ansible.  If not, see <http://www.gnu.org/licenses/>.


DOCUMENTATION = '''
---
module: win_file
version_added: "1.9.2"
short_description: Creates, touches or removes files or directories.
description:
     - Creates (empty) files, updates file modification stamps of existing files,
       and can create or remove directories.
       Unlike M(file), does not modify ownership, permissions or manipulate links.
notes:
    - See also M(win_copy), M(win_template), M(copy), M(template), M(assemble)
requirements: [ ]
author: "Jon Hawkesworth (@jhawkesworth)"
options:
  path:
    description:
      - 'path to the file being managed.  Aliases: I(dest), I(name)'
    required: true
    default: []
    aliases: ['dest', 'name']
  target:
    description:
      - 'path for a Windows shortcut (only applies to c(state=shortcut))'
    required: false
    default: []
    version_added: 2.2
  arguments:
    description:
      - 'arguments for a Windows shortcut (only applies to c(state=shortcut))'
    required: false
    default: []
    version_added: 2.2
  working_directory:
    description:
      - 'working directory for a Windows shortcut (only applies to c(state=shortcut))'
    required: false
    default: []
    version_added: 2.2
  state:
    description:
      - If C(directory), all immediate subdirectories will be created if they
        do not exist.
        If C(file), the file will NOT be created if it does not exist, see the M(copy)
        or M(template) module if you want that behavior.  If C(shortcut), a Windows
        shortcut will be created or changed, pointing to c(target).  If C(absent),
        directories will be recursively deleted, and files will be removed.
        If C(touch), an empty file will be created if the c(path) does not
        exist, while an existing file or directory will receive updated file access and
        modification times (similar to the way `touch` works from the command line).
    required: false
    default: file
    choices: [ file, directory, shortcut, touch, absent ]
'''

EXAMPLES = '''
# create a file
- win_file: path=C:\\temp\\foo.conf

# touch a file (creates if not present, updates modification time if present)
- win_file: path=C:\\temp\\foo.conf state=touch

# remove a file, if present
- win_file: path=C:\\temp\\foo.conf state=absent

# create directory structure
- win_file: path=C:\\temp\\folder\\subfolder state=directory

# remove directory structure
- win_file: path=C:\\temp state=absent

# chreate a shortcut
- win_file: path=C:\\temp\\foo.lnk target='bar.exe' arguments='1 2 3' state=shortcut
'''
