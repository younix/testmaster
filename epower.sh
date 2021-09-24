#!/bin/sh

set -eu

usage() {
	echo "epower [port] [1/0]" > /dev/stderr
	exit 1
}

if [ $# -ne 2 ]; then
	usage
fi

port=$1
action=$2

case "$action" in
"0")
	echo "power off, machine $machine, dev epower port $port"
	;;
"1")
	echo "power on, machine $machine, dev epower port $port"
	;;
*)
	usage
	;;
esac

timeout=$(($(date +%s) + 300));
while ! curl -s -u admin:admin -d "P${port}=${action}" -X POST \
    http://10.0.5.2/cmd.html; do
	if [ $(date +%s) -gt $timeout ]; then
		echo timeout
		exit 1
	fi
	sleep 1
	echo -n "retry epower $port $action "
	date
done
