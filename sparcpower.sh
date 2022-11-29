#!/bin/sh

set -eu

usage() {
	echo "sparcpower [port] [1/0]" > /dev/stderr
	exit 1
}

if [ $# -ne 2 ]; then
	usage
fi

port=$1
action=$2

case "$action" in
"0")
	echo "power off, machine $machine, send poweroff via lom"
	printf "\n#.\npoweroff -y\nconsole\n\005c." | console -f $machine
	;;
"1")
	echo "power on, machine $machine, send poweron via lom"
	printf "\n#.\npoweron\nconsole\n\005c." | console -f $machine
	;;
*)
	usage
	;;
esac
