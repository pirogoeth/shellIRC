#!/bin/bash
# required.sh -- setup a required configuration for a hooked module (in etc)

function require () {
	require=$1
	require="etc/$require"
	if [ ! -e $require ] ; then
		die "required configuration is nonexistant ($require)"
	fi
}
