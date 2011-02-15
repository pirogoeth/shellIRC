#!/usr/bin/env bash
# libparser.sh -- command parser for miyoko's shellbot

# include chat and channel management libraries and hook generator
. include/libchat.sh
. include/libchannel.sh
. modules/quotes.sh
. include/libhooks.sh

parse () {
	send_nick=$(echo ${@} | awk '{print $1}' | sed -e 's/://;s/!/ /')
	send_host=$(echo ${@} | awk '{print $1}' | sed -e 's/://;s/@/ /')
	send_fhost=$(echo ${@} | awk '{print $1}' | sed -e 's/://')
	recv_chan=$(echo ${@} | awk '{print $3}')
	send_nick=$(echo "$send_nick" | awk '{print $1}')
	send_host=$(echo "$send_host" | awk '{print $2}')
	command="$(echo ${@} | awk '{print $2}')"
	dest=$(echo ${@} | awk '{print $3}')
	text="${@:4}"
	cmd="$(echo $text | awk '{print $1}')"
	cmd="${cmd#:}"
	insert_hooks
	. include/libctcp.sh
	if [ "$(echo $cmd | awk '{print $1}' | cut -b 1)" == "$prefix" ] && [ "$command" == "PRIVMSG" ] || [ "$command" == "PONG" ] ; then
		if [ $(echo "$dest") == "$nick" ] && [ $(echo ${@} | awk '{print $4}') == "":"$prefix"ident"" ] && [ "$(pass_md5 $(echo ${@} | awk '{print $5}'))" == "$owner_pass" ] ; then
			user_host=$send_fhost
			notice $send_nick Identified.
		elif [ $(echo "$dest") == "$nick" ] && [ $(echo ${@} | awk '{print $4}') == "":"$prefix"ident"" ] && [ "$(pass_md5 $(echo ${@} | awk '{print $5}'))" != "$owner_pass" ] ; then
			user_host=""
			notice $send_nick Invalid.
		fi
		if [ $(echo "$dest") == "$nick" ] && [ $(echo ${@} | awk '{print $4}') == "":"$prefix"nickserv"" ] && [ -n "$(echo ${@} | awk '{print $5}')" ] ; then
			./modules/identify.sh $ns_user $(echo ${@} | awk '{print $5}') $socket
			notice $send_nick Identified to NickServ for username \`$ns_user\`.
		elif [ $(echo "$dest") == "$nick" ] && [ $(echo ${@} | awk '{print $4}') == "":"$prefix"nickserv"" ] && [ -z "$(echo ${@} | awk '{print $5}')" ] ; then
			notice $send_nick Invalid.
		fi
		if [ $(echo "$cmd" | cut -b 1-6) == $prefix"shell" ] ; then
			if [ $send_fhost == $user_host ] ; then
				rm etc/core_shell
				touch etc/core_shell
				echo "$(eval ${text#* } 2>&1 1>&1)" 1>etc/core_shell
				while read core_shell; do
					msg $dest $core_shell
				done < etc/core_shell
			else
				notice $send_nick Unauthorized access.
			fi
		fi
		if [ $(echo $cmd | cut -b 1-5) == $prefix"trim" ] ; then
			URL=$(echo $text | awk '{print $2}')
			echo "Trimmer active: $URL"
			trimmed=$(curl -s http://is.gd/api.php?longurl=$URL)
			ocount=$(echo $URL | wc -c)
			tcount=$(echo $trimmed | wc -c)
			if [ $(echo $trimmed | cut -b 1-6) == "Error:" ] ; then
				struct=$(echo "API ERROR!!!!")
				msg $dest $struct
				struct=$(echo "$trimmed")
				msg $dest $struct
			else
				struct=$(echo "Shortened URL: $trimmed  ::  URL was shortened by $(expr $ocount - $tcount) characters.  ::  Original URL is: $URL")
				msg $dest $struct
			fi
		fi
		if [ $(echo $cmd | cut -b 1-9) == $prefix"shutdown" ] ; then
			if [ "$send_fhost" == "$user_host" ] ; then
				echo "QUIT" >> $socket
				killall -TERM $$
				die "Received shutdown command"
			else
				notice $send_nick Unauthorized access.
			fi
		fi
		if [ $(echo $cmd | cut -b 1-5) == $prefix"push" ] ; then
			. include/libprowl.sh
		fi
		if [ $(echo $cmd | cut -b 1-5) == $prefix"join" ] ; then
			chan=$(echo $text | awk '{print $2}')
			join $chan
			unset chan
		fi
		if [ $(echo $cmd | cut -b 1-5) == $prefix"part" ] ; then
			chan=$(echo $text | awk '{print $2}')
			part $chan
			unset chan
		fi
		if [ $(echo $cmd | cut -b 1-6) == $prefix"cycle" ] ; then
			chan=$(echo $text | awk '{print $2}')
			cycle $chan
			unset chan
		fi
		if [ $(echo $cmd | cut -b 1-5) == $prefix"kick" ] ; then
			knick=$(echo $text | awk '{print $2}')
			kick $recv_chan $knick
			unset knick
		fi
		if [ $(echo $cmd | cut -b 1-7) == $prefix"uptime" ] ; then
			uptime=$(expr $(date +%s) - $boottime)
			msg $dest I have been running for $uptime seconds
			unset uptime
		fi
		if [ $(echo $cmd | cut -b 1-7) == $prefix"quote" ] ; then
			if [ $(echo $text | awk '{print $2}') == "add" ] ; then
				quote=$(echo $text | sed -e 's/\'$prefix'quote//g;s/add//;s/:  //;s/|/%/g;s/ /|/;s/ /|/g')
				addquote $quote
			fi
			if [ $(echo $text | awk '{print $2}') == "list" ] ; then
				listquotes
			fi
			if [ $(echo $text | awk '{print $2}') == "view" ] ; then
				fquote=$(echo $text | awk '{print $3}')
				viewquote $fquote
			fi
			if [ $(echo $text | awk '{print $2}') == "del" ] ; then
				dqnum=$(echo $text | awk '{print $3}')
				delquote $dqnum
			fi
			if [ $(echo $text | awk '{print $2}') == "search" ] ; then	
				search_param=$(echo $text | awk '{print $3}')
				searchquote $search_param
			fi
			if [ -z $(echo $text | awk '{print $2}') ] ; then
				echo "NOTICE $send_nick :"$prefix"quote [add|list|view|search|del] [# or term for search]" >> $socket
			fi
		fi

		if [ $(echo $cmd | cut -b 1-7) == $prefix"github" ] ; then
			. modules/github.sh
			repo=$(echo $text | awk '{print $2}')
			branch_s=$(echo $text | awk '{print $3}')
			github_repo_info $repo $branch_s
		fi
	fi
}