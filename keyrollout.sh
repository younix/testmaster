#!/bin/sh

set -eu

# FreeBSD, Linux, OpenBSD Test and virt KVM server
for m in /home/[flo]t[0-9]* /home/virt; do
	authfile="$m/.ssh/authorized_keys"
	echo -n "renew $authfile"
	rm -f "$authfile"
	for user in $(cat "$m/users" /home/test/users); do
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
