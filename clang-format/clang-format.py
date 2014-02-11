#
# clang-format.py
#
# This file is subject to the following LICENSE.TXT
#

#
# ==============================================================================
# LLVM Release License
# ==============================================================================
# University of Illinois/NCSA
# Open Source License
# 
# Copyright (c) 2007-2014 University of Illinois at Urbana-Champaign.
# All rights reserved.
# 
# Developed by:
# 
#    LLVM Team
# 
#    University of Illinois at Urbana-Champaign
# 
#    http://llvm.org
# 
# Permission is hereby granted, free of charge, to any person obtaining 
# a copy of this software and associated documentation files (the 
# "Software"), to deal with the Software without restriction, including 
# without limitation the rights to use, copy, modify, merge, publish, 
# distribute, sublicense, and/or sell copies of the Software, and to 
# permit persons to whom the Software is furnished to do so, subject to 
# the following conditions:
# 
#     * Redistributions of source code must retain the above copyright notice,
#       this list of conditions and the following disclaimers.
# 
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimers in the
#       documentation and/or other materials provided with the distribution.
# 
#     * Neither the names of the LLVM Team, University of Illinois at
#       Urbana-Champaign, nor the names of its contributors may be used to
#       endorse or promote products derived from this Software without specific
#       prior written permission.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE CONTRIBUTORS OR COPYRIGHT HOLDERS BE LIABLE FOR 
# ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
# CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION 
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS WITH THE SOFTWARE.
# 
# ==============================================================================
# The LLVM software contains code written by third parties.  Such software will
# have its own individual LICENSE.TXT file in the directory in which it appears.
# This file will describe the copyrights, license, and restrictions which apply
# to that code.
# 
# The disclaimer of warranty in the University of Illinois Open Source License
# applies to all code in the LLVM Distribution, and nothing in any of the
# other licenses gives permission to use the names of the LLVM Team or the
# University of Illinois to endorse or promote products derived from this
# Software.
# 
# The following pieces of software have additional or alternate copyrights,
# licenses, and/or restrictions:
# 
# Program             Directory
# -------             ---------
# <none yet>
# 


# This file is a minimal clang-format vim-integration. To install:
# - Change 'binary' if clang-format is not on the path (see below).
# - Add to your .vimrc:
#
#   map <C-I> :pyf <path-to-this-file>/clang-format.py<CR>
#   imap <C-I> <ESC>:pyf <path-to-this-file>/clang-format.py<CR>i
#
# The first line enables clang-format for NORMAL and VISUAL mode, the second
# line adds support for INSERT mode. Change "C-I" to another binding if you
# need clang-format on a different key (C-I stands for Ctrl+i).
#
# With this integration you can press the bound key and clang-format will
# format the current line in NORMAL and INSERT mode or the selected region in
# VISUAL mode. The line or region is extended to the next bigger syntactic
# entity.
#
# It operates on the current, potentially unsaved buffer and does not create
# or save any files. To revert a formatting, just undo.

import difflib
import json
import subprocess
import sys
import vim

# Change this to the full path if clang-format is not on the path.
binary = 'clang-format'

# Change this to format according to other formatting styles. See the output of
# 'clang-format --help' for a list of supported styles. The default looks for
# a '.clang-format' or '_clang-format' file to indicate the style that should be
# used.
style = 'file'

# Get the current text.
buf = vim.current.buffer
text = '\n'.join(buf)

# Determine range to format.
cursor = int(vim.eval('line2byte(line("."))+col(".")')) - 2
lines = '%s:%s' % (vim.current.range.start + 1, vim.current.range.end + 1)

# Avoid flashing an ugly, ugly cmd prompt on Windows when invoking clang-format.
startupinfo = None
if sys.platform.startswith('win32'):
  startupinfo = subprocess.STARTUPINFO()
  startupinfo.dwFlags |= subprocess.STARTF_USESHOWWINDOW
  startupinfo.wShowWindow = subprocess.SW_HIDE

# Call formatter.
command = [binary, '-lines', lines, '-style', style, '-cursor', str(cursor)]
if vim.current.buffer.name:
  command.extend(['-assume-filename', vim.current.buffer.name])
p = subprocess.Popen(command,
                     stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                     stdin=subprocess.PIPE, startupinfo=startupinfo)
stdout, stderr = p.communicate(input=text)

# If successful, replace buffer contents.
if stderr:
  message = stderr.splitlines()[0]
  parts = message.split(' ', 2)
  if len(parts) > 2:
    message = parts[2]
  print 'Formatting failed: %s (total %d warnings, %d errors)' % (
      message, stderr.count('warning:'), stderr.count('error:'))

if not stdout:
  print ('No output from clang-format (crashed?).\n' +
      'Please report to bugs.llvm.org.')
else:
  lines = stdout.split('\n')
  output = json.loads(lines[0])
  lines = lines[1:]
  sequence = difflib.SequenceMatcher(None, vim.current.buffer, lines)
  for op in reversed(sequence.get_opcodes()):
    if op[0] is not 'equal':
      vim.current.buffer[op[1]:op[2]] = lines[op[3]:op[4]]
  vim.command('goto %d' % (output['Cursor'] + 1))
