#!/bin/sh

set -eu

action="$1"

case "$action" in
0)
	echo "lom power off, machine $machine"
	command="poweroff -y"
	;;
1)
	echo "lom power on, machine $machine"
	command="poweron"
	;;
*)
	echo "lom unknown action: $action"
	exit 1
	;;
esac

printf "\n#.\n${command}\nconsole\n\005c." | console -f $machine
