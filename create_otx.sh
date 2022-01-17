#!/bin/sh

set -eux

no=$1
ip=$((no + 20))
env="/home/ot$no/env"
bak="/home/_backup/home/ot$no/"

id ot$no && exit 1

useradd -m -G test -c "OpenBSD Test $no" ot$no

if [ -e $bak/../.ssh/id_rsa ]; then
	cp $bak/.ssh/id_rsa* /home/ot$no/.ssh
else
	doas -u ot$no ssh-keygen -N "" -f /home/ot$no/.ssh/id_rsa
fi

cp /home/test/users /home/ot$no

mkdir -p $env
echo "10.0.1.$ip"	> /home/ot$no/env/ipaddr
echo "ot$no"		> /home/ot$no/env/machine
echo "toor"		> /home/ot$no/env/rootpw
echo "roottoor"		> /home/ot$no/env/userpw
echo "10.0.1.1"		> /home/ot$no/env/tftpserver
echo "10.0.1.2"		> /home/ot$no/env/sideserver
echo "10.0.1.3"		> /home/ot$no/env/setserver

cp $bak/env/arch	$env
cp $bak/env/hwaddr	$env
cp $bak/env/interface	$env

[ -e $bak/env/install ] && cp $bak/env/install $env

chown -R root:ot$no $env
chmod u=rwx,g=rx,o=rx $env
chmod u=rw,g=r,o=r $env/*

cd /var/spool/tftp
mkdir ot$no
chown ot$no:ot$no ot$no
ln -s ot$no 10.0.1.$ip

echo "10.0.1.$ip	ot$no" >> /etc/hosts

cat >> /etc/ssh/sshd_config <<EOF

Match User ot$no
	ForceCommand /home/test/bin/run.sh
	X11Forwarding no
	AllowAgentForwarding no
	PermitOpen 10.0.1.$ip:22
EOF

echo "console ot$no { include cyclades; device /dev/cuaXX; rw ot$no; }" >> /etc/conserver.cf
