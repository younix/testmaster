#!/bin/sh

set -eu

PATH="/home/test/bin:$PATH"

echo "power up machine $machine"

if ! timeout 60 ssh root@${ipaddr} true; then
	power.sh cycle

	if ! login.expect; then
		echo "no login prompt on machine $machine, send two newline"
		printf "\n\005c." | console -f $machine
		sleep 1
		printf "\n\005c." | console -f $machine
		sleep 1
		tail -n 16 "/var/consoles/$machine" | grep '^login: '
	fi
fi
