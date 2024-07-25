#!/bin/sh

set -eu

action=$1

case "$action" in
0)
	command="stop"
	;;
1)
	command="start"
	;;
*)
	echo "vmm unkown action: $action"
	exit 1
	;;
esac

echo "vmm $command, machine ${machine} on ${vmhost}"
ssh "${machine}@${vmhost}" "vmctl $command $machine"
