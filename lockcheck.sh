#!/bin/sh

set -e

lock=$(cat /home/$USER/lock)

if [ -z "$lock" ]; then
	exit 0
fi

if [ -z "$testuser" ]; then
	echo "testuser variable is not set"
	exit 1
fi

if [ "$lock" != "$testuser" ]; then
	exit 1
else
	exit 0
fi
