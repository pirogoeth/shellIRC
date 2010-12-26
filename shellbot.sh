#!/bin/bash
# shellbot.sh -- core for miyoko's shellbot

# include our config
. etc/core_config.sh

# setup the socket
socket="etc/core_input"

# setup for arguments and case it
while getopts "S:C:N:" flag
	do
		case "$flag" in
			S) export server="$OPTARG";export socket="tmp/$server"_input""
			;;
			C) export channel="$OPTARG"
			;;
			N) export nick="$OPTARG"
		esac
	done

# some tiny bit of setup
boottime=$(date +%s)

# empty out the socket
if [ -e $socket ] ; then
	echo '' > $socket
else
	touch $socket
fi

# simple variable for kickrejoin
one=1

# include our parse and channel management libraries
. include/libparser.sh
. include/libchannel.sh

# dump registration info into core_input
echo "NICK $nick" >> $socket
echo "USER $(whoami) +iw  $nick :$nick" >> $socket

# setup 'die' function
function die () {
	kill -9 $$
}

# include our require stuff
. include/required.sh

# start up the connection
tail -f $socket | telnet $server $port | \
while true
do read LINE || break
	echo "$LINE"
	# check for pings from the ircd
	if [ $(echo "$LINE" | awk '{print $1}') == "PING" ] ; then
		server_resp=$(echo "$LINE" | awk '{print $2}')
		echo "PONG $server_resp" >> $socket
	fi
	
	# make sure there wasnt an ERROR: for disconnect sent
	if [ $(echo "$LINE" | awk '{print $1}') == "ERROR:" ] ; then
		die
	fi

	# check is the nick was already in use
	if [ "$(echo "$LINE" | awk '{print $4}')" == "$nick" ] ; then
		nick="$nick-"
		echo "NICK $nick" >>$socket
	fi

	# check the perform to know when to join our channel
	if [ $(echo $LINE | awk '{print $2}' | cut -b 1) == "4" ] || [ "$(echo $LINE | awk '{print $2}' | cut -b 1)" == "3" ] ; then
		join $channel
	fi
	
	# parse each line in real time
	parse $LINE
	
	# log the line just for reference
	echo $LINE >> etc/core_log
	
	# check for a kick so we know to rejoin
	if [ $(echo "$LINE" | awk '{print $2}') == "KICK" ] ; then
		let one++
		rejoin
	fi
done
