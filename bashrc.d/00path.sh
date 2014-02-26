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
	export PATH
}

all-path-append () {
	libpath-append $1/lib64
	libpath-append $1/lib
	manpath-append $1/man
	path-append $1/bin
	pkg-config-path-append $1/lib/pkgconfig
	python-path-append $1/lib64/python2.7/site-packages
}

all-path-prepend () {
	libpath-prepend $1/lib
	libpath-prepend $1/lib64
	manpath-prepend $1/man
	path-prepend $1/bin
	pkg-config-path-prepend $1/lib/pkgconfig
	python-path-append $1/lib64/python2.7/site-packages
}
