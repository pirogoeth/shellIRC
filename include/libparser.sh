#!/bin/bash
# libparser.sh -- command parser for miyoko's shellbot

# include chat and channel management libraries and hook generator
. include/libchat.sh
. include/libchannel.sh
. modules/quotes.sh
. include/libhooks.sh

parse () {
	send_nick=$(echo ${@} | awk '{print $1}' | sed -e 's/://;s/!/ /')
	send_host=$(echo ${@} | awk '{print $1}' | sed -e 's/://;s/@/ /')
	recv_chan=$(echo ${@} | awk '{print $3}')
	send_nick=$(echo "$send_nick" | awk '{print $1}')
	send_host=$(echo "$send_host" | awk '{print $2}')
	command=$(echo ${@} | awk '{print $2}')
	dest=$(echo ${@} | awk '{print $3}')
	if [ $command == "PRIVMSG" ] ; then
		text=${@:4}
		cmd=$(echo "$text" | awk '{print $1}')
		cmd=${cmd#:}
		if [ $(echo "$cmd" | cut -b 1-6) == "^shell" ] ; then
			rm etc/core_shell
			touch etc/core_shell
			if [ $send_host == $user_host ] ; then
				echo "$(eval ${text#* })" > etc/core_shell 2> etc/core_shell
				while read core_shell; do
					msg $dest $core_shell
				done < etc/core_shell
			else
				notice $send_nick Unauthorized access.
			fi
		fi
		if [ $(echo $cmd | cut -b 1-5) == "^trim" ] ; then
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
				struct=$(echo "Shortened URL: $trimmed  ::  URL was shortened by $(expr $ocount - $tcount) characters.  ::  Originl URL is: $URL")
				msg $dest $struct
			fi
			#process_link $cmd $trimmed
		fi
		#if [ $(echo $cmd | cut -b 1-8) == "https://" ] ; then
		#	echo "Trimmer active: $cmd"
		#	trimmed=$(curl -s http://is.gd/api.php?longurl=$cmd)
		#	process_link $cmd $trimmed
		#fi
		if [ $(echo $cmd | cut -b 1-9) == "^shutdown" ] ; then
			if [ "$send_host" == "$user_host" ] ; then
				echo "QUIT" >> etc/core_input
				procname=$(echo "$0" | sed -e 's/\.\///;s/*\///')
				killall -TERM $procname
			else
				notice $send_nick Unauthorized access.
			fi
		fi
		if [ $(echo $cmd | cut -b 1-5) == "^push" ] ; then
			. include/libprowl.sh
		fi
		if [ $(echo $cmd | cut -b 1-5) == "^join" ] ; then
			chan=$(echo $text | awk '{print $2}')
			join $chan
			unset chan
		fi
		if [ $(echo $cmd | cut -b 1-5) == "^part" ] ; then
			chan=$(echo $text | awk '{print $2}')
			part $chan
			unset chan
		fi
		if [ $(echo $cmd | cut -b 1-6) == "^cycle" ] ; then
			chan=$(echo $text | awk '{print $2}')
			cycle $chan
			unset chan
		fi
		if [ $(echo $cmd | cut -b 1-5) == "^kick" ] ; then
			knick=$(echo $text | awk '{print $2}')
			kick $recv_chan $knick
			unset knick
		fi
		if [ $(echo $cmd | cut -b 1-7) == "^uptime" ] ; then
			uptime=$(expr $(date +%s) - $boottime)
			msg $dest I have been running for $uptime seconds
			unset uptime
		fi
		if [ $(echo $cmd | cut -b 1-7) == "^quote" ] ; then
			if [ $(echo $text | awk '{print $2}') == "add" ] ; then
				quote=$(echo $text | sed -e 's/\^quote//g;s/add//;s/:  //;s/|/%/g;s/ /|/;s/ /|/g')
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
				echo "NOTICE $send_nick :^quote [add|list|view|search|del] [# or term for search]" >> etc/core_input
			fi
		fi

		if [ $(echo $cmd | cut -b 1-7) == "^github" ] ; then
			. modules/github.sh
			repo=$(echo $text | awk '{print $2}')
			branch_s=$(echo $text | awk '{print $3}')
			github_repo_info $repo $branch_s
		fi
	
		insert_hooks
		
		 . include/libctcp.sh
	fi
}

. include/libtrimmer.sh
