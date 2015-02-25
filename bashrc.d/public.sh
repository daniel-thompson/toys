#
# public.sh
#
# Put ~/public on the various paths
#

# Add all the normal paths
if [ -e $HOME/Apps ]
then
	all-path-prepend $HOME/Apps
	PERL5LIB=$HOME/Apps/lib/perl
else
	all-path-prepend $HOME/public
	PERL5LIB=$HOME/public/lib/perl
fi

export PERL5LIB
