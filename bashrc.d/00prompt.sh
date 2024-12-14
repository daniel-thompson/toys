#
# prompt.sh
#
# Handle prompt display and per-line updates
#

[ -z $BBPATH ] && PS1="`hostname -s | tr A-Z a-z`\$ "

# Automatically update the title of the terminal emulator
function update_title() {
	case $TERM in
	(cygwin|x*term*|dtterm)
		echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/~}"
		echo -ne "\007"
		;;
	(alacritty|screen*|tmux*)
		printf "\033]2;${PWD/#$HOME/~}\033\\"
	esac
}

# Automatically update the environment from the tmux session.
# Comes from: http://www.johntobin.ie/blog/2011/06/
function update_tmux_session() {
	if [ -n "${TMUX}" ]; then
		local _tmux_env
		_tmux_env=$( tmux show-environment )
		if [ "${_tmux_env}" != "${_expected_tmux_env}" ]; then
			eval $( echo "${_tmux_env}" | \
				sed -e '/^-/!{ s/=/="/; s/$/"/; s/^/export /; }' \
				    -e 's/^-/unset /' \
				    -e 's/$/;/' )
			_expected_tmux_env="${_tmux_env}"
		fi
	fi
}

PROMPT_COMMAND='update_title; update_tmux_session'
# Exporting these confuses task shells is Zed (and there isn't really any need
# to export them. Every new interactive shell will source this file anyway.
#export -f update_title
#export -f update_tmux_session
#export PROMPT_COMMAND
