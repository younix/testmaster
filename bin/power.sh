#!/bin/sh

set -eu

usage() {
	echo "power [on|off|cycle]" > /dev/stderr
	exit 1
}

if [ $# -ne 1 ]; then
	usage
fi

action=$1

case "$action" in
"on")
	/home/test/bin/${powerdevice}.sh ${powerport} 1
	;;
"off")
	/home/test/bin/${powerdevice}.sh ${powerport} 0
	;;
"cycle")
	/home/test/bin/${powerdevice}.sh ${powerport} 0
	sleep 15
	/home/test/bin/${powerdevice}.sh ${powerport} 1
	;;
*)
	usage
	;;
esac
