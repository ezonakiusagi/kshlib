#!/bin/ksh
export FPATH=.
print $(colorize -c $1 -s "$2" -t $3)
