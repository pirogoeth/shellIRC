#!/usr/bin/env bash
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
		if [ "$request" == $'\001VERSION\001' ] ; then
			echo "RECEIVED CTCP VERSION: $recv_from"
			notice $recv_from VERSION shellbot by miyoko
		elif [ "$request" == $'\001TIME\001' ] ; then
			echo "RECEIVED CTCP TIME: $recv_from"
			notice $recv_from TIME $(date)
		fi
	fi
fi
