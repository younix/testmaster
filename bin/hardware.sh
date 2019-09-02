#!/bin/sh

# Copyright (c) 2019 Moritz Buhl <obsdlab@moritzbuhl.de>
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

set -eux

usage() {
	echo "$(basename $0) add/mod -A [arch] -D [powerdevice] -H [hwaddr]"
	echo "\t\t-I [interface] -P [powerport] machine#"
	exit 1
}

if [ $# -lt 2 ]; then
	usage
fi

cmd=$1; shift;

args=$(getopt A:D:H:I:P: $* || usage)
set -- $args
while [ $# -ne 0 ]; do
	case "$1"
	in
		-A)
			arch="$2"; shift; shift;;
		-D)
			powerdevice="$2"; shift; shift;;
		-H)
			hwaddr="$2"; shift; shift;;
		-I)
			interface="$2"; shift; shift;;
		-P)
			powerport="$2"; shift; shift;;
		--)
			shift; break;;
	esac
done

if [ $# -ne 1 ]; then
	usage
fi

machineid="$1"; shift;
echo $machineid | grep -qe ^[0-9][0-9]*$ || \
	(echo "'$machineid' is not a number" >&2 && exit 1)

machine="ot$machineid"
ipaddr="10.0.1.$((20 + machineid))"
environment="/home/$machine/env/"

if [ "$cmd" = add ]; then
	if [ -e /home/$machine ]; then
		echo "'/home/$machine' already exists, use 'mod'" >&2
		exit 1
	fi
	useradd -m -G test $machine
	mkdir -p $environment
elif [ "$cmd" = mod ]; then
	if [ ! -e /home/$machine ]; then
		echo "'/home/$machine' does not exist, use 'add'" >&2
		exit 1
	fi
else
	usage
fi

echo $machine > $environment/machine
echo $ipaddr > $environment/ipaddr

if [ -n "${arch:-}" ]; then
	echo "$arch" > $environment/arch
fi

if [ -n "${hwaddr:-}" ]; then
	n="[a-f0-9][a-f0-9]"
	re=$n:$n:$n:$n:$n:$n
	echo $hwaddr | grep -qe ^$re$ || \
		(echo "Warning: hwaddr is not a mac address" >&2 && hwaddr="")
	echo "$hwaddr" > $environment/hwaddr
fi

if [ -n "${interface:-}" ]; then
	re="[a-z][a-z]*[0-9][0-9]*"
	echo $interface | grep -qe ^$re$ || \
	echo "Warning: interface is not of format [a-z]+[0-9]+" >&2
	echo "$interface" > $environment/interface
fi

if [ -n "${powerdevice:-}" ]; then
	echo "$powerdevice" > $environment/powerdevice
fi

if [ -n "${powerport:-}" ]; then
	echo "$powerport" > $environment/powerport
fi

chown -R $machine:$machine $environment
chmod 775 $environment
for f in arch hwaddr interface ipaddr machine powerdevice powerport; do
	chmod 644 $environment/$f
done

if [ -z "${hwaddr:-}" ]; then
	exit
fi

new_dhcpd=$(mktemp)
existing=$(grep -ne $machine$ /etc/dhcpd.conf || echo "")
lines=$(wc -l < /etc/dhcpd.conf)
if [ -n "$existing" ]; then
	pos=$(echo $existing | cut -d: -f1)
	head -n$((pos - 1)) /etc/dhcpd.conf > $new_dhcpd
	after=$((lines - pos))
else
	grep -hB$lines ot /etc/dhcpd.conf > $new_dhcpd
	pos=$(wc -l <  $new_dhcpd)
	after=$((lines - pos))
fi
echo "host $machine {                                      hardware ethernet $hwaddr;                           fixed-address $ipaddr;                                        next-server 10.0.1.1;                           filename \"invalid\";                             } #$machine" >> $new_dhcpd
tail -n$after /etc/dhcpd.conf >> $new_dhcpd
mv $new_dhcpd /etc/dhcpd.conf
chown :test /etc/dhcpd.conf
chmod 664 /etc/dhcpd.conf

# XXX:
# add a line like:
# console ot15 { include cyclades; device /dev/cuac15; rw ot15; baud 115200; }
# to /etc/conserver.cf (or so)

