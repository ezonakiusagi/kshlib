#!/bin/ksh

# example sqlite wrapper using sqlite functions

# must define FPATH so we can use sqlite_* functions
FPATH=/usr/share/kshlib
importlib sqlite3 logging

# define references to external programs
SQLITE=/usr/bin/sqlite3
DATE=/bin/date

# define some vars
OPT_log_level=2
PID=$$

typeset -C dbc=(
    integer pid
    integer ifd
    integer ofd
    integer ready
)

sqlite_open ${1} dbc

quit=0
while (( quit == 0 )) ; do
    read input?"sqlite> "
    if [[ $input == end ]] ; then
	quit=1
    else
	sqlite_query dbc "$input" results
	ret=$?
	if (( $ret != 0 )) ; then
	    case $ret in
		1) print -u2 "[ERROR] database connection not ready" ;;
		2) print -u2 "[ERROR] database is locked" ;;
		3) print -u2 "[ERROR] unknown error" ;;
	    esac
	fi
	print -n -r -- "$results"
    fi
done

sqlite_close dbc
