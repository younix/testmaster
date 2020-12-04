#!/bin/sh

set -eu

PATH="/home/test/bin:$PATH"

if ! test -f /var/spool/tftp/$machine/memtest.bin; then
	echo "no memtest.bin in tftp directory"
	exit 1
fi

echo "turn on memtest86+ over pxe boot for machine $machine"

action="host $machine { 		\
	hardware ethernet $hwaddr;	\
	fixed-address $ipaddr;		\
	next-server $tftpserver;	\
	filename \"memtest.bin\";	\
} #$machine"

temp_file=`mktemp`
sed -e "s,^.*#$machine$,$action," /etc/dhcpd.conf > $temp_file
cat $temp_file > /etc/dhcpd.conf
rm -f $temp_file

doas /etc/rc.d/dhcpd restart
