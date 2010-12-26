#!/bin/bash
# libchat.sh -- messaging library for miyoko's shellbot

msg () {
	echo "PRIVMSG $1 :${@:2}" >> $socket
}
notice () {
	echo "NOTICE $1 :${@:2}" >> $socket
}

send_raw () {
	echo "${@:1}" >> $socket
}
