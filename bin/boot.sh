#!/bin/sh

set -eu

usage() {
	echo "boot [machine]" > /dev/stderr
	exit 1
}

tftpd_run() {
	tftpd.expect
}

tftp_dir="/home/${machine}/tftp"
files_dir="/home/${machine}/files"
www_root="/var/www/htdocs/"
www_dir="${www_root}/pub/OpenBSD/snapshots/${arch}/"
status_file="/var/www/users/${machine}/status"

set_status() {
	echo $1 > $status_file
}

set_status "prepare installation"
# prepare install.conf and siteXX.tgz file
mkinstcnf ${machine}
mksite ${machine}
cp ${files_dir}/${hwaddr}-install.conf $www_root
cp ${files_dir}/site${version}.tgz $www_dir

# index.txt update
ls -nT $www_dir > ${files_dir}/index.txt
cp ${files_dir}/index.txt $www_dir

#
# copy boot files into tftp directory
#
if [ -s "$www_dir/pxeboot" -a -s "$www_dir/bsd.rd" ]; then
	cp "$www_dir/pxeboot" "$tftp_dir/auto_install"
	cp "$www_dir/bsd.rd" "$tftp_dir/bsd"
	cp "$www_dir/bsd.rd" "$tftp_dir/bsd.rd"
else
	echo "could not found pxeboot file" > /dev/stderr
	exit 1
fi

on="host $machine { 			\
	hardware ethernet $hwaddr;	\
	fixed-address $ipaddr;		\
	filename \"auto_install\";	\
	next-server $srvaddr;		\
} #$machine"

off="host $machine { 			\
	hardware ethernet $hwaddr;	\
	fixed-address $ipaddr;		\
} #$machine"

set_dhcpd_conf() {
	case "$1" in
		"on")
			action=$on;;
		*)
			action=$off;;
	esac

	temp_file=`mktemp`
	sed -e "s/^.*#$machine$/$action/" /etc/dhcpd.conf > $temp_file
	cat $temp_file > /etc/dhcpd.conf
	rm -f $temp_file

	sudo /etc/rc.d/dhcpd restart
}

# generate random.seed file
mkdir -p ${tftp_dir}/etc
dd if=/dev/random of="${tftp_dir}/etc/random.seed" bs=512 count=1

set_dhcpd_conf on
set_status "boot installation"
power $machine offon
tftpd.expect		> /dev/null
set_status "start installation process"
httpd.expect		> /dev/null
set_dhcpd_conf off	> /dev/null
login.expect		> /dev/null
set_status "installation is done"
