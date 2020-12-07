#!/bin/sh

set -e

if [ -z "$lock" ]; then
	exit 0
fi

if [ "$lock" = "$testuser" ]; then
	exit 0
fi

echo "$machine is locked by $lock"
exit 1
