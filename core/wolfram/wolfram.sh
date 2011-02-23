#!/usr/bin/env bash

if test ! -z $1 && test "$1" == "help"; then
	echo "\x02Usage: ${prefix}wa <query>\x0a"
	exit 0
fi

if [ "$(echo $cmd | cut -b 1-3)" == $prefix"wa" ] ; then
	if test -e tmp/wrap; then msg $send_nick 'Query already in progress, try again in a few seconds.'; else
		touch tmp/wrap
                msg ${dest} "$(echo -en '\x02[WolframAlpha]: Searching...')"
		query=${text#* }
		if test -e tmp/wra ; then rm tmp/wra; touch tmp/wra; fi
		echo -en "${query}" | ./include/wolfram.py 2>&1 1>tmp/wra
		while read response
			do
				msg ${dest} "${response}"
			done < tmp/wra
		rm tmp/wrap
	fi
fi