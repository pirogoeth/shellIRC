#!/usr/bin/env bash
# shellbot.sh -- core for miyoko's shellbot

# define defaults and startup
config=${config:-"etc/core_config.sh"}
state="startup"

# include our config or die
if test ! -e $config; then
	echo "FATAL: config file \'${config}\' does not exist."; exit 1
else
	. $config
	unset config
fi

# setup for arguments and case it
while getopts "S:P:C:N:H:f:h" flag
	do
		case "$flag" in
			S) export server="$OPTARG";export socket="tmp/$server"_input""
			;;
			P) export port="$OPTARG"
			;;
			C) export channel="$OPTARG"
			;;
			N) export nick="$OPTARG"
			;;
			H) . include/libcompat.sh
			   pass_md5 $OPTARG; exit 0
			;;
			f) export config="$OPTARG"
			;;
			h) echo -en "`basename $0`: [-Sserver|-Pport|-Nnick|-Cchannel||-fconfigfile||-H password|-h]\x0aoptions do not have to be used in conjunction, you may use any option without the others.\x0a"; exit 0
		esac
	done

# redundancy
if test ! -z $config; then
	# include our config or die
	if test ! -e $config; then
		echo "FATAL: config file \'${config}\' does not exist."; exit 1
	else
		. $config
	fi
fi

# setup the socket
socket="etc/core_input"

# setup runtime with whatever the config says
case $core_debug in
	[Yy][Ee][Ss]) set -x
	;;
	[Nn][Oo])
	;;
	*) echo "WARNING: core_debug: variable not defined"
	;;
esac

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

# include our parsing, compatibility and channel management libraries
. include/libparser.sh
. include/libcompat.sh
. include/libchannel.sh

# dump registration info into core_input
echo "NICK $nick" >> $socket
echo "USER $(whoami) +iw  $nick :$nick" >> $socket

# setup 'die' function
function die () {
	state="halting"
	kill -9 $$
}

# include our require stuff
. include/required.sh

# start up the connection
tail -f $socket | telnet $server $port | \
while true
do read LINE || break
	# protect from the exploit that nukes bashIRC
	LINE=${LINE//\*/\\x2a}
	echo "$LINE"

	# check for pings from the ircd
	if [ $(echo "$LINE" | awk '{print $1}') == "PING" ] ; then
		server_resp=$(echo "$LINE" | awk '{print $2}')
		echo "PONG $server_resp" >> $socket
	fi

	# make sure there wasnt an ERROR: for disconnect sent
	if [ "$(echo \"${LINE}\" | awk '{print $1}')" == "ERROR" ] && [ ! "$state" == "halting" ] ; then
		echo "CONNECTION: server error occurred."
		if test "$core_reconn" == "yes"; then
			echo "Attempting to reconnect."
			$0 $*
		else
			echo "Aborting connection."
			exit 1
		fi
	fi

	# check if the nick was already in use
	if [ "$(echo "$LINE" | awk '{print $2}')" == "433" ] ; then
		nick="$nick-"
		echo "NICK $nick" >>$socket
	fi

	# check the perform to know when to join our channel
	if [ $(echo "$LINE" | awk '{print $2}' | cut -b 1) == "4" ] || [ "$(echo $LINE | awk '{print $2}' | cut -b 1)" == "3" ] ; then
		join $channel
	fi

	# parse each line in real time
	parse $LINE

	# log the line just for reference
	echo "$LINE" >> etc/core_log

	# check for a kick so we know to rejoin
	if [ $(echo "$LINE" | awk '{print $2}') == "KICK" ] && [ "$(echo $LINE | awk '{print $4}')" == "${nick}" ] ; then
		one=$((one++))
		rejoin $(echo $LINE | awk '{print $3}')
	fi
done