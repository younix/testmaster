#!/bin/sh

set -eu

PATH="/home/test/bin:$PATH"

echo "power down machine $machine"

if timeout 60 ssh root@${ipaddr} shutdown -p now power down by testmaster; then
	if ! syncingdisks.expect; then
		echo "no syncing disks on machine $machine"
	else
		# allow graceful power down
		sleep 5
	fi
fi

power.sh off
