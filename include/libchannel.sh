#!/bin/bash
# libchannel.sh -- channel management for miyoko's shellbot

# current channel commands (join, part)
rejoin () {
	if [ $one == "1" ] ; then
		echo "JOIN $channel" >> $socket
		let one--
	fi
}

join () {
	echo "JOIN $1" >> $socket
}

part () {
	echo "PART $1" >> $socket
}

cycle () {
	echo "PART $1" >> $socket
	echo "JOIN $1" >> $socket
}

# user commands (kick)

kick () {
	echo "KICK $1 $2 :Your behaviour is not conductive to the desired environment." >> $socket
}