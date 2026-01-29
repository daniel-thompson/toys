#
# 00path.sh
#
# Macros to grow the various PATH variables
#

libpath-append () {
	if [ -z "$LD_LIBRARY_PATH" ]
	then
		LD_LIBRARY_PATH=$1
	else
		echo $LD_LIBRARY_PATH | grep "$1" > /dev/null || \
			LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$1
	fi
	export LD_LIBRARY_PATH
}

libpath-prepend () {
	if [ -z "$LD_LIBRARY_PATH" ]
	then
		LD_LIBRARY_PATH=$1
	else
		echo $LD_LIBRARY_PATH | grep "$1" > /dev/null || \
			LD_LIBRARY_PATH=$1:$LD_LIBRARY_PATH
	fi
	export LD_LIBRARY_PATH
}

manpath-append () {
	# Do *NOT* change this logic to match libpath, man inserts the
	# default search into empty field
	echo $MANPATH | grep "$1" > /dev/null || \
		MANPATH=$MANPATH:$1
	export MANPATH
}

manpath-prepend () {
	echo $MANPATH | grep "$1" > /dev/null || \
		MANPATH=$1:$MANPATH
	export MANPATH
}

path-append () {
	echo $PATH | grep "$1" > /dev/null || \
		PATH=$PATH:$1
	export PATH
}

path-prepend () {
	echo $PATH | grep "$1" > /dev/null || \
		PATH=$1:$PATH
	export PATH
}

pkg-config-path-append () {
	if [ -z "$PKG_CONFIG_PATH" ]
	then
		PKG_CONFIG_PATH=$1
	else
		echo $PKG_CONFIG_PATH | grep "$1" > /dev/null || \
			PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$1
	fi
	export PKG_CONFIG_PATH
}

pkg-config-path-prepend () {
	if [ -z "$PKG_CONFIG_PATH" ]
	then
		PKG_CONFIG_PATH=$1
	else
		echo $PKG_CONFIG_PATH | grep "$1" > /dev/null || \
			PKG_CONFIG_PATH=$1:$PKG_CONFIG_PATH
	fi
	export PKG_CONFIG_PATH
}

python-path-append () {
	echo $PYTHONPATH | grep "$1" > /dev/null || \
		PYTHONPATH=$PYTHONPATH:$1
	export PYTHONPATH
}

python-path-prepend () {
	echo $PYTHONPATH | grep "$1" > /dev/null || \
		PYTHONPATH=$1:$PYTHONPATH
	export PYTHONPATH
}

xdg-data-dirs-append () {
	if [ -z "$XDG_DATA_DIRS" ]
	then
		XDG_DATA_DIRS=$1
	else
		echo $XDG_DATA_DIRS | grep "$1" > /dev/null || \
			XDG_DATA_DIRS=$XDG_DATA_DIRS:$1
	fi
	export XDG_DATA_DIRS
}

xdg-data-dirs-prepend () {
	if [ -z "$XDG_DATA_DIRS" ]
	then
		XDG_DATA_DIRS=$1
	else
		echo $XDG_DATA_DIRS | grep "$1" > /dev/null || \
			XDG_DATA_DIRS=$1:$XDG_DATA_DIRS
	fi
	export XDG_DATA_DIRS
}

python-site-packages () {
    local libdir=$(python -c "import sys; print('\n'.join(sys.path))" | grep 'lib[0-9]*/python[0-9][.][0-9][0-9]*$' | tail -n 1)
    echo $1/lib${libdir#*lib}/site-packages
}

all-path-append () {
	local arch=`uname -m`
	case $arch in
	aarch64)
		[ -d $1/$arch-linux-gnu ] \
			&& [ ! -e $1/$arch-linux-gnu/bin/objdump ] \
			&& all-path-prepend $1/$arch-linux-gnu
		;;
	esac

	[ -d $1/lib64 ] && libpath-append $1/lib64
	[ -d $1/lib ] && libpath-append $1/lib
	[ -d $1/man ] && manpath-append $1/man
	[ -d $1/bin ] && path-append $1/bin
	[ -d $1/lib/pkgconfig ] && pkg-config-path-append $1/lib/pkgconfig
	local pylib="$(python-site-packages $1)"
	[ -d $pylib ] && python-path-append $pylib
}

all-path-prepend () {
    [ -d $1/lib ] && libpath-prepend $1/lib
	[ -d $1/lib64 ] && libpath-prepend $1/lib64
	[ -d $1/man ] && manpath-prepend $1/man
	[ -d $1/bin ] && path-prepend $1/bin
	[ -d $1/lib/pkgconfig ] && pkg-config-path-prepend $1/lib/pkgconfig
	local pylib="$(python-site-packages $1)"
	[ -d $pylib ] && python-path-append $pylib

	local arch=`uname -m`
	case $arch in
	aarch64)
		[ -d $1/$arch-linux-gnu ] \
			&& [ ! -e $1/$arch-linux-gnu/bin/objdump ] \
			&& all-path-prepend $1/$arch-linux-gnu
		;;
	esac
}
