# flooder script

if [ "$(echo $cmd | cut -b 1-6)" == "^flood" ] && [ $send_host == $user_host ] ; then
	amt=$3
	dest=$4
	text=${@:5}

	i=0
	until [ $i == $amt ]
		do
			msg $dest $text
			i=$(expr $i + 1)
		done
fi
