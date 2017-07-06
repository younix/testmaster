#!/bin/sh

set -eu

dir="/home/${machine}/files/"
file="${dir}/${hwaddr}-install.conf"

mkdir -p ${dir}

cat > ${file} <<- EOF
	System hostname = ${machine}
	Password for root = ${rootpw}
	Public ssh key for root = ${sshkey}
	Network interfaces = ${interface}
	IPv4 address for ${interface} = dhcp
	Setup a user = user
	Password for user = ${userpw}
	Public ssh key for user = ${sshkey}
	Since you set up a user, disable sshd(8) logins to root = no
	What timezone are you in = Europe/Berlin
	Location of sets = http
	Server = ${srvaddr}
	Set name(s) = +site${version}.tgz
	Checksum test for site${version}.tgz failed. Continue anyway = yes
	Unverified sets: site${version}.tgz. Continue without verification = yes
EOF
