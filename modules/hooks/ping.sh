# ping module

if [ "$(echo "$cmd" | cut -b 1-5)" == $prefix"ping" ] ; then
	send_raw PING $send_nick
	ping_nick=$send_nick
	ping_send=$(date +%s.%N)
	ping_recv=$recv_chan
fi

if [ $command == "PONG" ] ; then
	ping_time=$(echo "$(date +%s.%N) - $ping_send" | bc)
	msg $ping_recv ping time for $ping_nick: $ping_time seconds
fi
