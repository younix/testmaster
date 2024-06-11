#!/bin/sh

set -eu

port=$1
status=$2

if [ ${status} -lt 0 -o ${status} -gt 2 ]; then
	echo "unkown status: ${status}"
	exit 1
fi

case "${status}" in
	"0")
	echo "power off, machine ${machine:--}"
	virsh destroy ${machine}
	;;

	"1")
	echo "power on, machine ${machine:--}"
	virsh start ${machine}
	;;

	"2")
	virsh reset ${machine}
	;;
esac
