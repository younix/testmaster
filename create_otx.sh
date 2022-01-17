#!/bin/sh

set -eux

nr=$1
ip=$((nr + 20))
env="/home/ot$nr/env"

id ot$nr && exit 1

useradd -m -G test -c "OpenBSD Test $nr" ot$nr

mkdir -p $env
echo "10.0.1.$ip"	> /home/ot$nr/env/ipaddr
echo "ot$nr"		> /home/ot$nr/env/machine
echo "toor"		> /home/ot$nr/env/rootpw
echo "roottoor"		> /home/ot$nr/env/userpw
echo "10.0.1.1"		> /home/ot$nr/env/tftpserver
echo "10.0.1.2"		> /home/ot$nr/env/sideserver
echo "10.0.1.3"		> /home/ot$nr/env/setserver

chown -R root:ot$nr $env
chmod u=rwx,g=rx,o=rx $env
chmod u=rw,g=r,o=r $env/*

cd /var/spool/tftp
mkdir ot$nr
chown ot$nr:ot$nr ot$nr
ln -s ot$nr 10.0.1.$ip

echo "10.0.1.$ip	ot$nr" >> /etc/hosts

#rm -f /home/ot$nr/.ssh/id_rsa*
doas -u ot$nr ssh-keygen -N "" -f /home/ot$nr/.ssh/id_rsa
