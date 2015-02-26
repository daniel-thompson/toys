#
# makej - automatically size make for the number of available processors
#

alias makej="make -j `cat /proc/cpuinfo  | grep processor | wc -l`"
