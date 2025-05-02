#!/bin/sh

set -eu

PATH="/home/test/bin:$PATH"

echo "reboot machine $machine"

timeout 60 ssh root@${ipaddr} shutdown -r now reboot by testmaster || \
	power.sh cycle

if ! login.expect; then
	echo "no login prompt on machine $machine, send two newline"
	printf "\n\005c." | console -f $machine
	sleep 1
	printf "\n\005c." | console -f $machine
	sleep 1
	tail -n 16 "/home/consoles/$machine" | grep '^login: '
fi
