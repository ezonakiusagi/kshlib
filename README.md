# kshlib
this repo will be a collection of ksh93 functions i've written so i can re-use for other projects.

# How to Use
set FPATH to include where 'importlib' and subdirectories are located. Then, in your
script, call importlib to pull in functions in the sub-diretories like so:

importlib colorize sqlite3

then the functions in those subdirectories should become available
