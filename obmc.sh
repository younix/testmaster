#!/bin/sh

set -eu

host=$1
user=$2
pass=$3
status=$4
action=

if [ -z "$host" -o -z "$user" -o -z "$pass" ]; then
	echo "insufficient settings"
	exit 1
fi

if [ ${status} -lt 0 -o ${status} -gt 1 ]; then
	echo "unkown status: ${status}"
	exit 1
fi

case "${status}" in
	"0")
	echo "power off, machine ${machine:--}"
	action="hardoff"
#	action="softoff"
	;;

	"1")
	echo "power on, machine ${machine:--}"
	action="on"
	;;
esac

/home/test/bin/openbmctool.py -H ${host} -U ${user} -P ${pass} chassis power ${action} > /dev/null
