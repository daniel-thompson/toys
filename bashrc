# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Source local definitions
for i in `find $HOME/.bashrc.d/ ! -type d | sort`
do
	. $i
done

