#!/bin/bash
# libchannel.sh -- channel management for miyoko's shellbot

# current channel commands (join, part)
rejoin () {
	if [ $one == "1" ] ; then
		echo "JOIN $channel" >> etc/core_input
		let one--
	fi
}

join () {
	echo "JOIN $1" >> etc/core_input
}

part () {
	echo "PART $1" >> etc/core_input
}

cycle () {
	echo "PART $1" >> etc/core_input
	echo "JOIN $1" >> etc/core_input
}

# user commands (kick)

kick () {
	echo "KICK $1 $2 :Your behaviour is not conductive to the desired environment." >> etc/core_input
}