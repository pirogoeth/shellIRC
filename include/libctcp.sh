#!/bin/bash
# libctcp.sh -- ctcp parsing for miyoko's shellbot

recv=$(echo ${@})
recv_from=$(echo $recv | awk '{print $1}' | sed -e 's/://;s/!/ /')
recv_from=$(echo $recv_from | awk '{print $1}')
recv_trig=$(echo $recv | awk '{print $2}')
recv_self=$(echo $recv | awk '{print $3}')
ctcp_req=$(echo $recv | awk '{print $4}')
ctcp_req=$(echo $ctcp_req | sed -e 's/://')
ctcp_req=$(echo $ctcp_req | tr -d [:space:])
request=$ctcp_req
if [ "$recv_trig" == "PRIVMSG" ] ; then
	if [ "$recv_self" == "$nick" ] ; then
		echo "*** Received CTCP $request from $recv_from ***" >> etc/core_ctcp
		if [ "$request" == $'\001VERSION\001' ] ; then
			notice $recv_from VERSION shellbot v2 by miyoko
		fi
		if [ "$request" == $'\001TIME\001' ] ; then
			notice $recv_from TIME $(date)
		fi
	fi
fi