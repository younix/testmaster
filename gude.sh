#!/bin/sh

set -eu

gude1="10.0.5.3"
gude2="10.0.5.4"
gude3="10.0.5.6"
gude4="10.0.5.7"

action="$1"

set -- $powerport

dev="$1"
port="$2"

if [ "$dev" -lt 1 -o "$dev" -gt 4 ]; then
	echo "unkown gude device number: $dev"
	exit 1
fi

eval gude="\${gude${dev}}"

if [ "$port" -lt 1 -o "$port" -gt 8 -a "$dev" -ne 4 -o "$port" -gt 12 ]; then
	echo "unkown gude port number: $port"
	exit 1
fi

case "$action" in
0)
	echo "gude power off, machine $machine, device $dev port $port"
	;;
1)
	echo "gude power on, machine $machine, device $dev port $port"
	;;
*)
	echo "gude unkown action: $action"
	exit 1
	;;
esac

curl -s "http://${gude}/ov.html?cmd=1&p=${port}&s=${action}" > /dev/null
