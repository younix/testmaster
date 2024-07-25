#!/bin/sh

set -eu

action="$1"

set -- $powerport

host="$1"
user="$2"
pass="$3"
driver="$4"

if [ -z "$host" -o -z "$user" -o -z "$pass" -o -z "$driver" ]; then
	echo "insufficient ipmi settings"
	exit 1
fi

case "$action" in
0)
	echo "ipmi power off, machine $machine"
	command="--off"
	;;
1)
	echo "ipmi power on, machine $machine"
	command="--on"
	;;
*)
	echo "ipmi unkown action: $action"
	exit 1
esac

ipmipower -h ${host} -u ${user} -p ${pass} -D ${driver} ${command} > /dev/null
