#!/usr/bin/env bash

host=${1}
port=${2}
format="${3}"

echo -en "HTTP/1.0 200 OK"
echo -en "Content-Type: text/plain"
echo -en '\x0a\x0a'

while read LINE
	do
		if [ ! "$(echo $LINE | awk '{print $2}')" == "/" ] ; then
			args="$(echo $LINE | awk '{print $2}')"
			args="${args//\// }"
			command="$(echo $args | awk '{print $1}')"
			params="$(echo $args | awk '{print $2}')"
			mpc -h $host -p $port --format="$format" ${command} ${params} 2>&1 1>&1
			exit
		else
			mpc -h $host -p $port --format="$format" status 2>&1 1>&1
			echo -en '\x0a\x0aCurrent Playlist:\x0a\x0a'
			mpc --no-status -h $host -p $port playlist | grep --line-number ""
			exit
		fi
	done