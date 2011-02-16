#!/usr/bin/env bash
# identify module for miyoko's shellbot

if test ! -z $1 && test "$1" == "help"; then
	echo "\x02Usage: /msg ${nick} ${prefix}nickserv <account_pass>"
	exit 0
fi

socket="./$3"
echo "PRIVMSG NickServ :id $1 $2" >> $socket
