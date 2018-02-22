#!/bin/ksh
FPATH=/usr/share/kshlib
importlib colorize
print $(colorize -c $1 -s "$2" -t $3)
