EDITOR=nfedit
WINEDITOR=edit
XEDITOR=edit

alias e=edit

tmux-fullscreen () {
	case "$1" in
	n*|f*)
		tmux set -guq @fullscreen
		;;
	*)
		tmux set -gq @fullscreen y
		;;
	esac
}

export EDITOR WINEDITOR XEDITOR
