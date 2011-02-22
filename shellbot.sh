#!/usr/bin/env bash
# shellbot.sh -- core for miyoko's shellbot

# setup config
config="etc/core_config.sh"

# config check
if test ! -z $config; then
	# include our config or die
	if test ! -e $config; then
		echo "FATAL: config file \'${config}\' does not exist."; exit 1
	else
		. $config
	fi
fi

# setup for arguments and case it
while getopts "S:P:C:N:H:f:hbB" flag
	do
		case "$flag" in
			S) export server="$OPTARG";if test ! -e "tmp/${server}_input"; then export socket="tmp/${server}_input"; elif test -e "tmp/${server}_input"; then export socket="tmp/${server}_input_"; fi
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
			f) export cust_conf="yes";export config="$OPTARG"
			;;
			h) echo -en "`basename $0`: [-Sserver|-Pport|-Nnick|-Cchannel||-fconfigfile||-H password|-h]\x0aoptions do not have to be used in conjunction, you may use any option without the others.\x0aDO NOT SPECIFY -f with -S, -P, -C, OR -N.\x0a"; exit 0
			;;
			b) export backgrounded="yes"
			;;
			B) export running="yes"
			;;
		esac
	done

# config stuff
if test "$cust_conf" == "no"; then
	config="etc/core_config.sh"
elif test "$cust_conf" == "yes"; then
	# include our config or die
	if test ! -e $config; then
		echo "FATAL: config file \'${config}\' does not exist."; exit 1
	else
		. $config
	fi
fi

# setup the socket
socket="tmp/${server}.socket"

# setup runtime with whatever the config says
case "$core_debug" in
	[Yy][Ee][Ss]) set -x
	;;
	[Nn][Oo]) echo "CORE: debugging off"
	;;
esac

# see if we need to background and do so, if needed
case "$core_bck" in
	[Yy][Ee][Ss]) if test "$backgrounded" == "yes"; then
			echo "CORE: backgrounded"
		      elif test ! "$backgrounded" == "yes"; then
		        echo "CORE: backgrounding..."
		        { nohup $0 $* -b 2>&1 1>>tmp/${server}.console & disown; exit 0; }; exit 0
		      fi

	;;
	[Nn][Oo]) if test "$running" == "yes"; then
		    echo "CORE: running"
		  elif test ! "$running" == "yes"; then
		    echo "CORE: not backgrounding."
		    { tail -f tmp/${server}.console & nohup $0 $* -B 2>&1 1>>tmp/${server}.console; }
		  fi
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

# setup the nohup log
if test -e tmp/${server}.console; then
	echo '' >tmp/${server}.console
else
	touch tmp/${server}.console
fi

# simple variable for kickrejoin
one=1

# include our parsing, help, compatibility and channel management libraries
. include/libparser.sh
. include/libcompat.sh
. include/libchannel.sh
. include/libhelp.sh

# include our require stuff
. include/required.sh

# prepare to generate help
export prefix=${prefix}

# generate help
help.generate

# dump registration info into core_input
echo "NICK $nick" >> $socket
echo "USER $(whoami) +iw  $nick :$nick" >> $socket

# setup 'die' function
function die () {
	state="halting"
	kill -9 $$
}

# start up the connection and enter main loop
echo -en "CORE: entering main loop\x0a\x0a"
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
	if [ "$(echo ${LINE} | awk '{print $1}')" == "ERROR" ] && [ ! "$state" == "halting" ] ; then
		echo "CONNECTION: server error occurred."
		if test "$core_reconn" == "yes"; then
			echo "CORE: reconnecting"
			{ $0 $*; }
		else
			echo "CONNECTION: abort"
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

	# check for a kick so we know to rejoin
	if [ $(echo "$LINE" | awk '{print $2}') == "KICK" ] && [ "$(echo $LINE | awk '{print $4}')" == "${nick}" ] ; then
		one=$((one++))
		rejoin $(echo $LINE | awk '{print $3}')
	fi

	# parse each line in real time
	parse $LINE

	# log the line just for reference
	echo "$LINE" >> etc/core_log
done