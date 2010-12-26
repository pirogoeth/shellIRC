#!/bin/bash
# required.sh -- setup a required configuration for a hooked module (in etc)

function require () {
	require="$1"
	require="etc/$require"
	if [ ! -e $require ] ; then
		echo "required configuration is nonexistant ($require)"
		killall -TERM shellbot.sh
	fi
}
