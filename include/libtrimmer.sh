#!/bin/bash
# libtrimmer.sh -- url trimmer for miyoko's shellbot

process_link () {
	struct="Shrunk URL: $trimmed -- Title: $(curl -s $1 | egrep -o "(<title>|<TITLE>)(.*)(</title>|</TITLE>)" | sed -e 's/<title>//g;s/<\/title>//g;s/<TITLE>//g;s/<\/TITLE>//g')"
	msg $dest $struct
}