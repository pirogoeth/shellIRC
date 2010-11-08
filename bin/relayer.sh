#!/bin/bash
# relayer.sh -- relayer core for miyoko's relaybot.sh

relay_1 () {
	target=etc/relayer/relay_core-1
	echo "PRIVMSG $channel1 :${@}" >> $target
}

relay_2 () {
	target=etc/relayer/relay_core-2
	echo "PRIVMSG $channel2 :${@}" >> $target
}

conn_open_1 () {
	# dump registration info into reader
	echo "NICK $3" >> etc/relayer/relay_core-1
	echo "USER $(whoami) +iw  $3 :$3" >> etc/relayer/relay_core-1

	# start up the connection
	tail -f etc/relayer/relay_core-1 | telnet $1 6667 | \
	while true
	do read LINE || break
		echo "$LINE"
		# check for pings from the ircd
		if [ $(echo "$LINE" | awk '{print $1}') == "PING" ] ; then
			server_resp=$(echo "$LINE" | awk '{print $2}')
			echo "PONG $server_resp" >> etc/relayer/relay_core-1
		fi

		# check the perform to know when to join our channel
		if [ "$(echo $LINE | awk '{print $2}' | cut -b 1)" == "3" ] ; then
			if [ -z $sonce ] ; then
				connmsg=$(echo "Now connected to $server1 $channel1")
				join $2 1
				sleep .5s
				relay_2 $connmsg
				sonce=1
			fi
		fi

		# setup line and relay each line in real time
		command=$(echo $LINE | awk '{print $2}')
		if [ "$command" == "PRIVMSG" ] ; then
			relaysetup=$(echo $LINE | awk '{print $1}' | sed -e 's/!/ /' | awk '{print $1}')
			relaysetup=$(echo $relaysetup | sed -e 's/://')
			function e_text () { echo ${@:4} | sed -e 's/://'; }
			text=$(e_text $LINE)
			if [ "$(echo $text | awk '{print $1}')" == $'\001ACTION' ] ; then
				action="$(echo $text | tr -d $'\001ACTION')"
				action="$(echo $action | tr -d $\')"
				MSG=$(echo "- $relaysetup/$server1 $action")
			else
				MSG=$(echo "<$relaysetup/$server1> $text")
			fi
			relay_2 $MSG
		fi
		if [ "$command" == "JOIN" ] ; then
			if [ ! "$(echo $LINE | sed -e 's/!/ /;s/://' | awk '{print $1}')" == "$(echo $tnick1)" ] ; then
				uparse=$(echo $LINE | awk '{print $1}')
				uparse=$(echo $uparse | sed -e 's/!/ /;s/://')
				unick=$(echo $uparse | awk '{print $1}')
				uhost=$(echo $uparse | awk '{print $2}')
				MSG=$(echo "--- $unick ($uhost) joined the remote channel ---")
				relay_2 $MSG
			fi
		fi
		if [ "$command" == "PART" ] ; then
			if [ ! "$(echo $LINE | sed -e 's/!/ /;s/://' | awk '{print $1}')" == "$tnick1" ] ; then
				uparse=$(echo $LINE | awk '{print $1}')
				uparse=$(echo $uparse | sed -e 's/!/ /;s/://')
				unick=$(echo $uparse | awk '{print $1}')
				uhost=$(echo $uparse | awk '{print $2}')
				MSG=$(echo "--- $unick ($uhost) parted the remote channel ---")
				relay_2 $MSG
			fi
		fi
		if [ "$command" == "QUIT" ] ; then
			if [ ! "$(echo $LINE | sed -e 's/!/ /;s/://' | awk '{print $1}')" == "$tnick1" ] ; then
				uparse=$(echo $LINE | awk '{print $1}')
				uparse=$(echo $unick | sed -e 's/!/ /;s/://')
				unick=$(echo $uparse | awk '{print $1}')
				uhost=$(echo $uparse | awk '{print $2}')
				function e_text () { echo ${@:4} | sed -e 's/://'; }
				reason=$(e_text $LINE)
				MSG=$(echo "--- $unick ($uhost) quit the remote server: $reason ---")
				relay_2 $MSG
			fi
		fi
		
		# log the line just for reference
		echo $LINE >> etc/relayer/relay_log-1
	
		# check for a kick so we know to rejoin
		if [ $(echo "$LINE" | awk '{print $2}') == "KICK" ] ; then
			let one++
			rejoin $channel1 1
		fi
	done
}

conn_open_2 () {
	# dump registration info into reader
	echo "NICK $3" >> etc/relayer/relay_core-2
	echo "USER $(whoami) +iw  $3 :$3" >> etc/relayer/relay_core-2

	# start up the connection
	tail -f etc/relayer/relay_core-2 | telnet $1 6667 | \
	while true
	do read LINE || break
		echo "$LINE"
		# check for pings from the ircd
		if [ $(echo "$LINE" | awk '{print $1}') == "PING" ] ; then
			server_resp=$(echo "$LINE" | awk '{print $2}')
			echo "PONG $server_resp" >> etc/relayer/relay_core-2
		fi

		# check the perform to know when to join our channel
		if [ "$(echo $LINE | awk '{print $2}' | cut -b 1)" == "3" ] ; then
			if [ -z $sonce ] ; then
				connmsg=$(echo "Now connected to $server2 $channel2")
				join $2 2
				sleep .5s
				relay_1 $connmsg
				sonce=1
			fi
		fi

		# setup line and relay each line in real time
		command=$(echo $LINE | awk '{print $2}')
		if [ "$command" == "PRIVMSG" ] ; then
			relaysetup=$(echo $LINE | awk '{print $1}' | sed -e 's/!/ /' | awk '{print $1}')
			relaysetup=$(echo $relaysetup | sed -e 's/://')
			function e_text () { echo ${@:4} | sed -e 's/://'; }
			text=$(e_text $LINE)
			if [ "$(echo $text | awk '{print $1}')" == $'\001ACTION' ] ; then
				action="$(echo $text | tr -d $'\001ACTION')"
				action="$(echo $action | tr -d $\')"
				MSG=$(echo "- $relaysetup/$server2 $action")
			else
				MSG=$(echo "<$relaysetup/$server2> $text")
			fi
			relay_1 $MSG
		fi
		if [ "$command" == "JOIN" ] ; then
			if [ ! "$(echo $LINE | sed -e 's/!/ /;s/://' | awk '{print $1}')" == "$tnick2" ] ; then
				uparse=$(echo $LINE | awk '{print $1}')
				uparse=$(echo $uparse | sed -e 's/!/ /;s/://')
				unick=$(echo $uparse | awk '{print $1}')
				uhost=$(echo $uparse | awk '{print $2}')
				MSG=$(echo "--- $unick ($uhost) joined the remote channel ---")
				relay_1 $MSG
			fi
		fi
		if [ "$command" == "PART" ] ; then
			if [ ! "$(echo $LINE | sed -e 's/!/ /;s/://' | awk '{print $1}')" == "$tnick2" ] ; then
				uparse=$(echo $LINE | awk '{print $1}')
				uparse=$(echo $uparse | sed -e 's/!/ /;s/://')
				unick=$(echo $uparse | awk '{print $1}')
				uhost=$(echo $uparse | awk '{print $2}')
				MSG=$(echo "--- $unick ($uhost) parted the remote channel ---")
				relay_1 $MSG
			fi
		fi
		if [ "$command" == "QUIT" ] ; then
			if [ ! "$(echo $LINE | sed -e 's/!/ /;s/://' | awk '{print $1}')" == "$tnick2" ] ; then
				uparse=$(echo $LINE | awk '{print $1}')
				uparse=$(echo $uparse | sed -e 's/!/ /;s/://')
				unick=$(echo $uparse | awk '{print $1}')
				uhost=$(echo $uparse | awk '{print $2}')
				function e_text () { echo ${@:4} | sed -e 's/://'; }
				reason=$(e_text $LINE)
				MSG=$(echo "--- $unick ($uhost) quit the remote server: $reason ---")
				relay_1 $MSG
			fi
		fi

		# log the line just for reference
		echo $LINE >> etc/relayer/relay_log-2
	
		# check for a kick so we know to rejoin
		if [ $(echo "$LINE" | awk '{print $2}') == "KICK" ] ; then
			let one++
			rejoin $channel2 2
		fi
	done
}