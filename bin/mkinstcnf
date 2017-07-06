#!/bin/sh

set -eu

dir="/home/${1:-}/env"
prog="${0}.sh"

if [ ! -d "$dir" ]; then
	echo "unknown machine: ${1:-}" >> /dev/stderr
	exit 1
fi

if [ ! -x "$prog" ]; then
	echo "unknown command: $prog" >> /dev/stderr
	exit 1
fi

shift 1

exec envdir $dir $prog "${@:-}"
