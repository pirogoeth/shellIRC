# a shoutcast module for radio.diytto

if [ "$(echo $cmd | cut -b 1-4)" == "^scd" ] ; then
	url="http://radio.diytto.com:7331/7.html"
	data=$(curl -A "Mozilla" -s $url)
	data=$(echo $data | sed -re 's/<(HTML|\/html)>//g;s/<meta(.*)\">//g;s/<(head|\/head)>//g;s/<(body|\/body)>//g')
	data=$(echo $data | sed -e 's/ /\|/g;s/,/ /g')
	tune_url=$(curl -s http://is.gd/api.php?longurl=http://radio.diytto.com:7331/)
	listener_c=$(echo $data | awk '{print $3}')
	listener_t=$(echo $data | awk '{print $4}')
	bitrate=$(echo $data | awk '{print $6}')
	songinfo=$(echo $data | awk '{print $7}' | sed -e 's/|/ /g')
	struct="Playing on Diytto Radio: [[$songinfo]==[$bitrate Kbps]==[$listener_c/$listener_t listeners]==[URL: $tune_url]]"
	msg $dest $struct
fi