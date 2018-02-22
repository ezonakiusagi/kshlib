#!/bin/ksh

# must define FPATH so we can use sqlite_* functions
FPATH=/usr/share/kshlib
importlib logging sqlite3

# define external program references
SQLITE=/usr/bin/sqlite3
DATE=/bin/date

# define variables
OPT_log_level=2
PID=$$
NL=$'\n'

typeset -C sqlite_conn=(
	integer pid
	integer ifd
	integer ofd
	integer ready
)

##
## open pipe to sqlite in functions
##
print "Using pipe to sqlite in functions"
sqlite_open /var/lib/pcapfiledb/pcapfile.sqlite3 sqlite_conn
print "sqlite_conn=${sqlite_conn}"

# get all files into a list
typeset -a LIST=( $(/bin/ls -U1 /pcap-dummy0/*) )
total_files=${#LIST[*]}

count_ones=0
count_zeros=0
count_files=0

start=$(date +%s.%N)
print "starting sqlite function benchmark: ${start}"
for file in ${LIST[*]}
do
	(( count_files++ ))
	#print -n "processing ${count_files}/${total_files}\r"
	got_answer=0

	while (( $got_answer == 0 ))
	do
		sqlite_query sqlite_conn "SELECT COUNT(file) FROM filedb WHERE file == \"${file}\";" answer

		if [[ $answer == 0${NL} ]] ; then
			(( count_zeros++ ))
			got_answer=1
		elif [[ $answer == 1${NL} ]] ; then
			(( count_ones++ ))
			got_answer=1
		elif [[ $answer == Error*"database is locked"* ]] ; then
			print -n "database is locked while counting $file\r"
		else
			print -u2 "what the hell??? [$answer][$file]"
			got_answer=1
			exit 1
		fi
	done
done
print "processing ${count_files}/${total_files}"
print "found $count_zeros zeros"
print "found $count_ones ones"
end=$(date +%s.%N)
print "stopping pipe benchmark: ${end}"
duration=$(echo "$end - $start" | bc)
print "total duration = ${duration}"

sqlite_close sqlite_conn

##
## open pipe to sqlite directly without functions
##

sqlite3 /var/lib/pcapfiledb/pcapfile.sqlite3 |&
exec 3>&p 4<&p

# get all files into a list
typeset -a LIST=( $(/bin/ls -U1 /pcap-dummy0/*) )
total_files=${#LIST[*]}

count_ones=0
count_zeros=0
count_files=0

start=$(date +%s.%N)
print "starting direct pipe benchmark: ${start}"
for file in ${LIST[*]}
do
	(( count_files++ ))
	#print -n "processing ${count_files}/${total_files}\r"
	got_answer=0
	while (( $got_answer == 0 ))
	do
		print -u3 -- "SELECT COUNT(file) FROM filedb WHERE file == \"${file}\";"
		read -t 1 -u4 -r answer

		if [[ $answer == 0 ]] ; then
			(( count_zeros++ ))
			got_answer=1
		elif [[ $answer == 1 ]] ; then
			(( count_ones++ ))
			got_answer=1
		elif [[ $answer == Error*"database is locked"* ]] ; then
			print -n "database is locked while counting $file\r"
		else
			print -u2 "what the hell??? $answer"
		fi
	done
done
print "processing ${count_files}/${total_files}"
print "found $count_zeros zeros"
print "found $count_ones ones"
end=$(date +%s.%N)
print "stopping pipe benchmark: ${end}"
duration=$(echo "$end - $start" | bc)
print "total duration = ${duration}"
# close I/O to sqlite
exec 3>&-
exec 4<&-
kill $!

# temporary break
#exit 

##
## fork sqlite for each query
##
count_ones=0
count_zeros=0
count_files=0
start=$(date +%s.%N)
print "starting fork benchmark: ${start}"
for file in ${LIST[*]}
do
	(( count_files++ ))
	#print -n "processing ${count_files}/${total_files}\r"
	got_answer=0
	while (( $got_answer == 0 ))
	do
		answer=$(sqlite3 /var/lib/pcapfiledb/pcapfile.sqlite3 "SELECT COUNT(file) FROM filedb WHERE file == \"${file}\";" 2>/dev/null)
		ret=$?
		if (( $ret == 0 )) ; then
			got_answer=1
		elif (( $ret == 5 )) ; then
			# database is locked, try again
			print "database locked, re-trying."
		else
			# bad shit happened
			print "bad shit happened = $ret"
		fi
	done
	if [[ $answer == 0 ]] ; then
		(( count_zeros++ ))
	elif [[ $answer == 1 ]] ; then
		(( count_ones++ ))
	else
		print -u2 "what the hell??? $answer"
	fi
done
print "processing ${count_files}/${total_files}"
print "found $count_zeros zeros"
print "found $count_ones ones"
end=$(date +%s.%N)
print "stopping fork benchmark: ${end}"
duration=$(echo "$end - $start" | bc)
print "total duration = ${duration}"

exit 0
