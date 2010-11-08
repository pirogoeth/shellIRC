#!/bin/bash
# libchat.sh -- messaging library for miyoko's shellbot

msg () {
	echo "PRIVMSG $1 :${@:2}" >> etc/core_input
}
notice () {
	echo "NOTICE $1 :${@:2}" >> etc/core_input
}
