#!/bin/sh

set -eux

PATH="/home/test/bin:$PATH"

echo "turn $1 pxe boot for machine $machine"

case "$1" in
"on")
	action="host $machine { \
hardware ethernet $hwaddr; \
fixed-address $ipaddr; \
next-server $tftpserver; \
filename \"boot\"; \
} #$machine"
	;;
"install")
	action="host $machine { \
hardware ethernet $hwaddr; \
fixed-address $ipaddr; \
next-server $tftpserver; \
filename \"auto_install\"; \
} #$machine"
	;;
"upgrade")
	action="host $machine { \
hardware ethernet $hwaddr; \
fixed-address $ipaddr; \
next-server $tftpserver; \
filename \"auto_upgrade\"; \
} #$machine"
	;;
"off")
	action="host $machine { \
hardware ethernet $hwaddr; \
fixed-address $ipaddr; \
next-server $tftpserver; \
filename \"invalid\"; \
} #$machine"
	;;
*)
	echo "unknown command $1"
	exit 1
	;;
esac

temp_file=`mktemp`
sed -e "s,^.*#$machine$,$action," /etc/dhcpd.conf > $temp_file
cat $temp_file > /etc/dhcpd.conf
rm -f $temp_file

doas /etc/rc.d/dhcpd restart
