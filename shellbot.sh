#!/bin/bash
# shellbot.sh -- core for miyoko's shellbot

# include our configuration
. etc/core_config.sh

# check if we identify or not
case $1 in
	-i)
	identify="yes"
	;;
esac

# some tiny bit of setup
boottime=$(date +%s)

# empty out core_input
if [ -e ./etc/core_input ] ; then
	echo '' > etc/core_input
else
	touch etc/core_input
fi

# simple variable for kickrejoin
one=1

# include our parse and channel management libraries
. include/libparser.sh
. include/libchannel.sh

# dump registration info into core_input
echo "NICK $nick" >> etc/core_input
echo "USER $(whoami) +iw  $nick :$nick" >> etc/core_input

# start up the connection
tail -f etc/core_input | telnet $server 6667 | \
while true
do read LINE || break
	echo "$LINE"
	# check for pings from the ircd
	if [ $(echo "$LINE" | awk '{print $1}') == "PING" ] ; then
		server_resp=$(echo "$LINE" | awk '{print $2}')
		echo "PONG $server_resp" >> etc/core_input
	fi

	# check the perform to know when to identify
	if [ $(echo $LINE | awk '{print $2}') == "250" ] ; then
		if [ "$identify" == "yes" ] ; then
			. modules/identify.sh $ns_user $ns_pass
			unset ns_user ns_pass
		fi
	fi
	# check the perform to know when to join our channel
	if [ $(echo $LINE | awk '{print $2}') == "376" ] || [ $(echo $LINE | awk '{print $2}') == "366" ] ; then
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