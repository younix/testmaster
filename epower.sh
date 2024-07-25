#!/bin/sh

set -eu

action="$1"

set -- $powerport

port="$1"

if [ "$port" -lt 1 -o "$port" -gt 4 ]; then
	echo "unkown epower port number: $port"
	exit 1
    fi

case "$action" in
0)
	echo "epower off, machine $machine, port $port"
	;;
1)
	echo "epower on, machine $machine, port $port"
	;;
*)
	echo "epower unknown action: $action"
	exit 1
	;;
esac

timeout=$(($(date +%s) + 300));
# curl may print "401 Authorization Required", retry until it is quiet
while curl -s -u admin:admin --basic -d "P${port}=${action}" -X POST \
    http://10.0.5.2/cmd.html | grep .; do
	if [ $(date +%s) -gt $timeout ]; then
		echo timeout
		exit 1
	fi
	sleep 1
	echo -n "retry epower $port $action "
	date
done
