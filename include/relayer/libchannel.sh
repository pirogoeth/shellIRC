#!/usr/bin/env bash
# libchannel.sh -- channel management for miyoko's shellbot

# current channel commands (join, part)
rejoin () {
	if [ $one == "1" ] ; then
		echo "JOIN $1" >> etc/relayer/relay_core-$2
		let one--
	fi
}

join () {
	echo "JOIN $1" >> etc/relayer/relay_core-$2
}
