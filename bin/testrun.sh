#!/bin/sh

set -eu

t="${HOME}/tests/$1"

if [ -x "$t" ]; then
	exec $t
fi

if [ "auto" = "$1" ]; then
	for t in `grep -v ^# ${HOME}/files/test_list`; do
		testrun $machine $t
	done
fi

echo "test: $t does not exist" > /dev/stderr
exit 1
