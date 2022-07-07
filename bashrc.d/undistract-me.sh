# Copyright (c) 2008-2012 undistract-me developers. See LICENSE for details.
#

# Check for interactive bash and that we haven't already been sourced.
[ -z "$BASH_VERSION" -o -z "$PS1" -o -n "$last_command_started_cache" ] && return

# Don't engage undistriction when we're not in an SSH session (gnome-terminal
# has a built-in notifier for local commands)
[ -z "$SSH_CLIENT" ] && return

# Don't engage undistraction unless xprop is working properly
xprop -root _NET_ACTIVE_WINDOW > /dev/null 2> /dev/null || return

. $HOME/Projects/daniel-thompson/toys/undistract-me/long-running.bash
notify_when_long_running_commands_finish_install
