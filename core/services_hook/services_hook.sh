#!/usr/bin/env bash
# services_access -- module for miyoko's shellbot

if test ! -z $1 && test "$1" == "help"; then
	echo "\x02Usage: <tag>->command args\x0a"
	exit 0
fi

require servsaxx.def.sed

if [ ! -z $(echo $text | awk '{print $1}' | grep -E -o -m1 "\->" | tr -d [:space:]) ] && [ "$send_fhost" == "$user_host" ] ; then
	if [ $(echo $cmd | cut -b 1-2) == ":>" ] ; then
		break 1
	fi
	target=$(echo $text | sed -e 's/->/ /;s/://')
	target_c=$(echo $text | sed -e 's/->//;s/://')
	target_service_short=$(echo $target | awk '{print $1}')
	target_service=$(echo $target_service_short | sed -rf etc/servsaxx.def.sed)
	target_argv=${target_c:2}
	if [ "$target_service_short" == "sr" ] ; then
		echo "$target_argv" >> $socket
	else
		msg $target_service $target_argv
	fi
fi