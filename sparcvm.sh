#!/bin/sh

set -eu

action="$1"

case "$action" in
0)
	command="off"
	;;
1)
	command="on"
	;;
*)
	echo "unkown action: $action"
	exit 1
	;;
esac

echo "sparc $command, machine $machine on $vmhost"
ssh "$machine@$vmhost" "$command"
