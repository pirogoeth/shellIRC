#!/bin/bash
# quotes.sh -- quotes module for miyoko's shellbot

addquote () {
	qtext=$(echo "'$1'")
	ts=$(echo "@@@ added by $send_nick at $(date)")
	ts=$(echo $ts | sed -e 's/|/%/g;s/ /|/g')
	echo "$qtext|$ts" >> etc/mod_quotes
	msg $dest $send_nick, your quote was added.
}

listquotes () {
	qlist=$(cat etc/mod_quotes | grep --line-number "")
	for quote in $qlist
		do
			notice $send_nick $(echo $quote | sed -e 's/|/ /g;s/%/|/g;s/:/: /')
		done
}

viewquote () {
	quote=$(cat etc/mod_quotes | grep --line-number "" | egrep -o -m1 "$1:.*")
	quote=$(echo $quote | sed -e 's/|/ /g;s/%/|/g;s/:/: /')
	msg $recv_chan $quote
}

delquote () {
	qlist=$(cat etc/mod_quotes | grep --line-number "" | sed -e 's/'$1':.*//' | awk '{if($0) { print $0}}')
	if [ -e etc/mod_quotes.tmp ] ; then
		rm etc/mod_quotes.tmp
		touch etc/mod_quotes.tmp
	fi
	for item in $qlist
		do
			echo $item >> etc/mod_quotes.tmp
		done
	if [ ! -e etc/mod_quotes.tmp ] ; then
		rm etc/mod_quotes
		touch etc/mod_quotes
	else
		mv etc/mod_quotes.tmp etc/mod_quotes
	fi
}

searchquote () {
	search=$(echo $1)
	qlist=$(cat etc/mod_quotes | grep --line-number "" | grep "$search")
	for result in $qlist
		do 
			result=$(echo $result | sed -e 's/|/ /g;s/%/|/g;s/:/: /')
			notice $send_nick $result
		done
}