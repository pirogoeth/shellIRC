#!/usr/bin/env bash

if test ! -z $1 && test "$1" == "help"; then
	echo "\x02Usage: \x0a${prefix}np\x0a${prefix}update\x0a${prefix}httpd\x0a${prefix}mpc <commands>\x0a"
	exit 0
fi

host='maio.me'
port='3000'
format='Now Playing: [[%title%] - [%artist%] - [%album%]] [(%time%)] [@ {%file%}]'
bindip='178.162.240.65'
bindport='8020'
allow='yes'

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

if [ "$(echo $cmd | cut -b 1-6)" == $prefix"httpd" ] && [ "$send_fhost" == "$user_host" ] ; then
	if [ "$allow" == "yes" ] && [ ! -e tmp/httpd.pid ] ; then
		msg $dest $(echo -en '\x02\x0310,1Starting MPC Web server...')
		tcpserver -Drv $bindip $bindport ./modules/hooks/code/mpc-httpd.sh $host $port "$format" 2>&1 1>&1 &
		echo $! >tmp/httpd.pid
		msg $dest $(echo -en "\x02\x0310Started. Now Listening on "$bindip":"$bindport)
		msg $dest $(echo -en "\x02\x0310Type "$prefix"httpd again to stop")
	elif [ "$allow" == "yes" ] && [ -e tmp/httpd.pid ] ; then
		msg $dest $(echo -en '\x02\x0310Killing PID '$(cat tmp/httpd.pid)'...')
		eval 'kill -9 `cat tmp/httpd.pid`'
		msg $dest $(echo -en "\x02\x0310Kill finished with status: $?")
		rm tmp/httpd.pid
	else
		msg $dest $(echo -en '\x02\x036Stopped. Change the allow option in modules/hooks/mpd.sh to yes to use the httpd')
	fi
fi