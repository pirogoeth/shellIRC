#!/usr/bin/env bash

if test ! -z $1 && test "$1" == "help"; then
	echo "\x02Usage: ${prefix}gt <query>>\x0a"
fi

if [ "$(echo $cmd | cut -b 1-3)" == "${prefix}gt" ] ; then
	touch tmp/gt
	query=${text#* }
	{ ./include/googletrans.py ${query} 2>&1 1>>tmp/gt; }
	while read gt
		do
			msg ${dest} ${gt}
		done < tmp/gt
	rm tmp/gt
fi