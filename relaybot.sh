#!/bin/bash
# relaybot.sh -- core for miyoko's IRC relaybot

# include our configuration
. etc/relayer/core_config.sh

# some tiny bit of setup
boottime=$(date +%s)

# empty out relay cores
if [ -e ./etc/relayer/relay_core-1 ] ; then
	echo '' > etc/relayer/relay_core-1
else
	touch etc/relayer/relay_core-1
fi
if [ -e ./etc/relayer/relay_core-2 ] ; then
	echo '' > etc/relayer/relay_core-2
else
	touch etc/relayer/relay_core-2
fi

# simple variable for kickrejoin
one=1

# include channel management
. include/relayer/libchannel.sh

# include our connector
. bin/relayer.sh

# start up the connections
conn_open_1 $server1 $channel1 $tnick1 | conn_open_2 $server2 $channel2 $tnick2