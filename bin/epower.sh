#!/bin/sh

set -eu

usage() {
	echo "epower [port] [1/0]" > /dev/stderr
	exit 1
}

if [ $# -ne 1 ]; then
	usage
fi

port=$1
action=$2

case "$status" in
"0")
	echo "power off, machine $machine, dev $dev port $port"
	;;
"1")
	echo "power on, machine $machine, dev $dev port $port"
	;;
esac

echo "p${port}=${status}" > /dev/tty01
