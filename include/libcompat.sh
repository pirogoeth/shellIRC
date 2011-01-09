#!/usr/bin/env bash
# libcompat.sh -- for compatibility with other systems

function pass_md5 () {
	if [ -z $(which md5sum) ] ; then
		retr=$(echo $1 | md5)
		retr=$(echo $retr | sed -e 's/-//g' | tr -d [:blank:])
		echo $retr
		return 1
	elif [ -n $(which md5sum) ] ; then
		retr=$(echo $1 | md5sum -)
		retr=$(echo $retr | sed -e 's/-//g' | tr -d [:blank:])
		echo $retr
		return 1
	fi
}
