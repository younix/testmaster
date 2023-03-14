#!/bin/sh

set -e

if [ -z "$testuser" ]; then
	echo "empty testuser variable"
	exit 1
fi

lock=$(cat /home/$USER/lock)

if [ -z "$lock" ]; then
	echo "$machine already unlocked"
	exit 0
fi

if [ "$lock" = "$testuser" ]; then
	:> /home/$USER/lock
	echo "$machine unlocked"
	exit 0
else
	echo "$machine is locked by $lock"
	exit 1
fi
