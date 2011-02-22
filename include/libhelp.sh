#!/usr/bin/env bash
# help library, lolwut

function help.retrieve () {
	search=${@}
	what=${search// /_}
	result=$(cat tmp/bot.help | grep -m1 "${what}:")
	if test -z "$result"; then
		msg ${send_nick} $(echo -en "\x02No help topics available for '${search}'\x0a")
	elif test ! -z "$result"; then
		retr=$(echo "$result" | sed -e 's/ /_/g;s/:/ /')
		help_title=$(echo ${retr} | awk '{print $1}')
		help_content=$(echo ${retr} | awk '{print $2}')
		help_content=${help_content//_/ }
		msg ${send_nick} $(echo -en "\x02Help for ${help_title}:")
		msg ${send_nick} $(echo -en "${help_content}")
	fi
}

function help.generate () {
	chmod 755 modules/*.sh modules/hooks/*.sh
	if test -e tmp/bot.help; then rm tmp/bot.help; fi
	for module in $(ls modules/*.sh)
		do
			name=${module##*/}
			echo "${name%.*}:$(eval $module help)" >>tmp/bot.help
			echo "CORE: generated help for ${module}"
		done
	for hook in $(ls modules/hooks/*.sh)
		do
			name=${hook##*/}
			echo "${name%.*}:$(eval $hook help)" >>tmp/bot.help
			echo "CORE: generated help for ${hook}"
		done
}

function help.list () {
	msg ${send_nick} $(echo -en '\x02Help topics:\x0a')
	for line in $(cat tmp/bot.help | sed -e 's/ /_/g')
		do
			topic=${line%%:*}
			msg ${send_nick} $(echo -en "\x02-${topic}")
		done
}