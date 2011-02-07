#!/usr/bin/env bash

if [ "$(echo $cmd | cut -b 1-5)" == $prefix"meme" ] ; then
	req=$(curl -s http://api.autome.me/text?lines=1)
	colourlist="10,4 7,3 2,9 6,7 5,3 6,2 40,2 15,3"
	colour=$({ shuf $colourlist || shuffle $colourlist ; } | head -n +1)
	msg $dest $(echo -en "\x02\x03$colour$req\x0a")
fi