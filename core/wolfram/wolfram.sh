#!/usr/bin/env bash

if [ "$(echo $cmd | cut -b 1-3)" == $prefix"wa" ] ; then
	if test -e tmp/wrap; then msg $send_nick 'Query already in progress, try again in a few seconds.'; else
		msg ${dest} "$(echo -en '\x02[WolframAlpha]: Searching...')"
		query=${text#* }
		echo $query
		touch tmp/wrap
		if test -e tmp/wra ; then rm tmp/wra; touch tmp/wra; fi
		echo "$query" | ./include/wolfram.py 2>&1 1>tmp/wra
		while read response
			do
				msg ${dest} "${response}"
			done < tmp/wra
		rm tmp/wrap
	fi
fi