#!/bin/sh

set -eu

if [ $# -ne 1 ]; then
	echo "usage: bsdcons.sh console-log-file" >&2
	exit 1;
fi

if ! [ -r "$1" ]; then
	echo "console log file '$1' not readable" >&2
	exit 1;
fi

tr -d '\r' <"$1" | 
    sed -n '/^Copyright (c) 1982, 1986, 1989, 1991, 1993$/{x;d;};H;${x;p;}'
