#!/bin/bash
# identify module for miyoko's shellbot

socket="./$3"
echo "PRIVMSG NickServ :id $1 $2" >> $socket