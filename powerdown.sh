#!/bin/sh

set -eux

PATH="/home/test/bin:$PATH"

echo "power down machine $machine"

if ssh root@${ipaddr} shutdown -p now power down by testmaster; then
	if ! syncingdisks.expect; then
		echo "no syncing disks on machine $machine"
	else
		# allow graceful power down
		sleep 5
	fi
fi

power.sh off
