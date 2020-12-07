#!/bin/sh

set -eu

for m in /home/ot*/users; do
	authfile="$(dirname "$m")/.ssh/authorized_keys"
	echo -n "renew $authfile"
	rm -f "$authfile"
	for user in $(cat "$m"); do
		if [ ! -s "/home/test/sshkeys/$user" ]; then
			echo "$user in $m does not have a key" > /dev/stderr
			continue
		fi
		echo -n " $user"
		sed -e "s/^/environment=\"testuser=$user\" /" \
		    "/home/test/sshkeys/$user" >> "$authfile"
	done
	echo
done
