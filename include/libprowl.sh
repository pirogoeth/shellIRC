#!/usr/bin/env bash
# libprowl.sh -- prowl push support for miyoko's shellbot

sender="$send_nick"
prowl_list=etc/core_prowl
prowl_target=$(echo $text | awk '{print $2}')
for item in $(cat $prowl_list)
	do
		if [ "$(echo $item | sed -e 's/-.*//g')" == "$prowl_target" ] ; then
				apikey=$(echo $item | sed -e 's/.*-//g')
				send_push=$(curl -k https://prowl.weks.net/publicapi/add -d apikey=$apikey -d application=$nick -d description=$send_nick\ has\ called\ for\ you\ in\ irc://$server/$recv_chan)
				# parse the api return
				parse_line=$(echo $send_push | grep -Eo "<success(.*) />")
				parse_return=$(echo $parse_line | tr -d [:alpha:] | sed -e 's/"//g;s/=//g;s/<//g;s/\/>//g;s/ //')
				# reparse the data that was parsed by the parser
				if [ "$(echo $parse_return | awk '{print $1}')" == "200" ] ; then
					#msg $dest message pushed, returned code: $(echo $parse_return | awk '{print $1}')
					#msg $dest remaining api calls: $(echo $parse_return | awk '{print $2}') -- count resets @ $(echo $parse_return | awk '{print $3}') UTC
					msg $dest Process returned $(echo $parse_return | awk '{print $1}') :: $(echo $parse_return | awk '{print $2}') API calls remaining.
				else
					msg $dest push failed.
				fi
		fi
	done
