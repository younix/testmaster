#!/bin/sh

set -eu

for file in arch machine version mirror; do
	if [ ! -s $file ]; then
		echo "$file is not set" > /dev/stderr
		exit 1
	fi
done

exit 0
