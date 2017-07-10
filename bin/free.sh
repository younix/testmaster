#!/bin/sh

set -e

if [ -z "$testuser" ]; then
	echo "empty testuser variable"
	exit 1
fi

if [ -z "$lock" ]; then
	echo "$machine is free"
	exit 0
fi

if [ "$lock" = "$testuser" ]; then
	rm /home/$USER/env/lock
	echo "$machine is free"
	exit 0
else
	echo "$machine is locked by $lock"
	exit 1
fi
