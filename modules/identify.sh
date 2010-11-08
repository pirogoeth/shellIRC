#!/bin/bash
# identify module for miyoko's shellbot

echo "PRIVMSG NickServ :id $1 $2" >> etc/core_input
shift