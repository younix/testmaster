#!/bin/sh

set -eu

port=$1
status=$2

if [ ${status} -lt 0 -o ${status} -gt 1 ]; then
	echo "unkown status: ${status}"
	exit 1
fi

case "${status}" in
	"0")
	echo "power off, machine ${machine:--}"
	ssh t4 off
	;;

	"1")
	echo "power on, machine ${machine:--}"
	ssh t4 on
	;;
esac
