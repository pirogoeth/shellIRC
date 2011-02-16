#!/usr/bin/env bash
# forwards

if test ! -z $1 && test "$1" == "help"; then
	echo "\x02Usage:\x0a${prefix}forward <channame>\x0a${prefix}unforward\x0a"
	exit 0
fi

if [ "$(echo $cmd)" == ">forward" ] && [ "$send_fhost" == "$user_host" ] ; then
	export f_nick=$send_nick
	export f_chan=$(echo $text | awk '{print $2}')
	export f_bool="true"
fi

if [ "$(echo $cmd)" == ">unforward" ] && [ "$send_fhost" == "$user_host" ] ; then
	unset f_nick f_chan f_bool
fi

if [ "$f_bool" == "true" ] && [ -n $f_chan ] && [ -n $f_nick ] && [ "$recv_chan" == "$f_chan" ] ; then
	text=$(echo $text | sed -e 's/:/ /;s/\*/\\*/g')
	msg $f_nick \<$send_nick\:$f_chan\> $text
fi