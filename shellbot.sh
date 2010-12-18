#!/bin/bash
# shellbot.sh -- core for miyoko's shellbot

# include our config
. etc/core_config.sh

# setup for arguments and case it
args=`getopt :ib $*`
set -- $(echo $args | sed -e 's/--//g')

for i
	do
		case "$i" in
			-i)
			identify="yes"
			;;
			-b)
			$0 $(echo $args | sed -e 's/-b//g;s/--//g') & disown
			exit 0
			;;
		esac
	done

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

# setup 'die' function
function die () {
	kill -9 $$ 
}

# include our require stuff
. include/required.sh

# start up the connection
tail -f etc/core_input | telnet $server $port | \
while true
do read LINE || break
	echo "$LINE"
	# check for pings from the ircd
	if [ $(echo "$LINE" | awk '{print $1}') == "PING" ] ; then
		server_resp=$(echo "$LINE" | awk '{print $2}')
		echo "PONG $server_resp" >> etc/core_input
	fi
	
	# make sure there wasnt an ERROR: for disconnect sent
	if [ $(echo "$LINE" | awk '{print $1}') == "ERROR:" ] ; then
		die
	fi

	# check is the nick was already in use
	if [ "$(echo "$LINE" | awk '{print $4}')" == "$nick" ] ; then
		nick="$nick-"
		echo "NICK $nick" >>etc/core_input
	fi

	# check the perform to know when to identify
	if [ $(echo $LINE | awk '{print $2}' | cut -b 1) == "4" ] ; then
		if [ "$identify" == "yes" ] ; then
			. modules/identify.sh $ns_user $ns_pass
			unset ns_user ns_pass
		fi
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
