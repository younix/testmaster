#!/bin/sh

set -eu

action="$1"

set -- $powerport

host="$1"
user="$2"
pass="$3"

if [ -z "$host" -o -z "$user" -o -z "$pass" ]; then
	echo "insufficient bmc settings"
	exit 1
fi

case "$action" in
0)
	echo "bmc power off, machine $machine"
	command="hardoff"
#	command="softoff"
	;;
1)
	echo "bmc power on, machine $machine"
	command="on"
	;;
*)
	echo "bmc unkown action: $action"
	exit 1
	;;
esac

/home/test/bin/openbmctool.py -H ${host} -U ${user} -P ${pass} chassis power \
    ${command} >/dev/null
