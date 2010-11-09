#!/bin/bash
# libhooks.sh -- library for hooking user triggers and modules into the parser

hooks=$(ls modules/hooks/*.sh)

pass_line () {
	trigger=$1
	text=${@:2}
	. $trigger
}

insert_hooks () {
	for trigger in $hooks
		do
			pass_line $trigger $text
		done
}