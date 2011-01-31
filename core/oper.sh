#!/bin/bash
# oper.sh -- hook in to shellbot for opering up the bot

if [ "$(echo $cmd | cut -b 1-5)" == "^oper" ] ; then
	. etc/mod_oper.sh
	echo "OPER $oper_username $oper_password" >> etc/core_input
fi
