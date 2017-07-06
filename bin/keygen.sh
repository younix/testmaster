#!/bin/sh

dir=/home/${machine}/site/etc/ssh/

mkdir -p $dir

for type in rsa1 dsa ecdsa ed25519 rsa; do
	file="${dir}/ssh_host_${type}_key"
	if [ ! -s "$file" ] ; then
		ssh-keygen -qt $type -N "" -f "$file"
	fi
done
