#!/bin/sh

set -eux

no=$1
ip=$((no + 20))

id ot$no || exit 1

userdel ot$no
groupdel ot$no
rm -r /home/ot$no

rm -r /var/spool/tftp/ot$no
rm /var/spool/tftp/10.0.1.$ip

ed -s /etc/hosts <<-EOF
	/10.0.1.$ip/d
	w
EOF
