#!/bin/sh

set -eux

PATH="/home/test/bin:$PATH"

echo "reboot machine $machine"

ssh root@${ipaddr} shutdown -r now || power.sh cycle

if ! login.expect; then
	echo "no login prompt on machine $machine, send two newline"
	printf "\n\005c." | console -f $machine
	sleep 1
	printf "\n\005c." | console -f $machine
	login.expect
fi
