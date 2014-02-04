#
# public.sh
#
# Put ~/public on the various paths
#

# Add all the normal paths
all-path-prepend $HOME/public

# Include my personal perl5 library
PERL5LIB=$HOME/public/lib/perl
export PERL5LIB
