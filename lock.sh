#!/bin/sh

set -e

if [ -z "$testuser" ]; then
	echo "empty testuser variable"
	exit 1
fi

lock=$(cat /home/$USER/lock)

if [ -z "$lock" ]; then
	echo "$testuser" > /home/$USER/lock
	echo "$machine locked"
	exit 0
fi

echo "$machine is locked by $lock"

if [ "$lock" != "$testuser" ]; then
	exit 1
else
	exit 0
fi
