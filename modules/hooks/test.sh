#!bin/bash
# test.sh -- trigger :: example w/ embedded code

if [ $(echo $cmd | cut -b 1-5) == "^test" ] ; then
	msg $dest test hook worked.
fi