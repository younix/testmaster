#!/bin/sh

set -eu

for ot in `ls /home | grep ot`; do
	chown root:$ot		/home/$ot
	chmod o=rwx,g=rx,o=rx	/home/$ot

	chown root:$ot		/home/$ot/users
	chmod o=rw,g=r,o=r	/home/$ot/users

	chown root:$ot		/home/$ot/env
	chmod o=rwx,g=rx,o=rx	/home/$ot/env

	chown root:$ot		/home/$ot/env/*
	chmod o=rw,g=r,o=r	/home/$ot/env/*

	chown root:$ot		/home/$ot/.ssh
	chmod o=rwx,g=rx,o=	/home/$ot/.ssh

	chown root:$ot		/home/$ot/.ssh/authorized_keys
	chmod o=rw,g=r,o=r	/home/$ot/.ssh/authorized_keys

	chown $ot:$ot		/home/$ot/.ssh/id_rsa
	chmod o=rw,g=,o=	/home/$ot/.ssh/id_rsa

	chown $ot:$ot		/home/$ot/.ssh/id_rsa.pub
	chmod o=rw,g=r,o=r	/home/$ot/.ssh/id_rsa.pub
done
