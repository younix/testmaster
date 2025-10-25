#!/bin/sh

set -eu

# FreeBSD, Linux, OpenBSD Test and kvm and virt KVM server
for m in /home/[flo]t[0-9]* /home/kvm /home/virt; do
	authfile="$m/.ssh/authorized_keys"
	echo -n "renew $authfile"
	rm -f "$authfile"
	case "$m" in
	/home/kvm|/home/virt)
		users="$(cat $m/users)"
		;;
	*)
		users="$(cat $m/users /home/test/users)"
		;;
	esac
	for user in $users; do
		if [ ! -s "/home/test/sshkeys/$user" ]; then
			echo "$user in $m does not have a key" >&2
			continue
		fi
		echo -n " $user"
		sed -e "s/^/environment=\"testuser=$user\" /" \
		    "/home/test/sshkeys/$user" >> "$authfile"
	done
	echo
done
