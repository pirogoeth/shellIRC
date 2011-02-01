#!/usr/bin/env bash

host='maio.me'
port='3000'
format='Now Playing: [[%title%] - [%artist%] - [%album%]] [(%time%)] [@ {%file%}]'

if [ "$(echo $cmd | cut -b 1-7)" == $prefix"update" ] ; then
	retr=$(mpc -h ${host} -p ${port} update)
	msg $dest $retr
fi

if [ "$(echo $cmd | cut -b 1-3)" == $prefix"np" ] ; then
	retr=$(mpc -h ${host} -p ${port} --format="${format}" current)
	msg $dest $retr
fi

if [ "$(echo $cmd | cut -b 1-4)" == $prefix"mpc" ] ; then
	param=${text#* }
	retr=$(mpc -h $host -p $port --format="${format}" ${param} 2>&1 1>&1)
	msg $dest $retr
fi
