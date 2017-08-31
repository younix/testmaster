#!/bin/sh

set -eux

PATH="/home/test/bin:$PATH"

echo "start installation of the current snapshot on machine $machine"

mk_install_conf() {
	rm -f ${1}

	cat > ${1} <<- EOF
		System hostname = ${machine}
		DNS domain name = obsd-lab.genua.de
		Password for root = ${rootpw}
		Public ssh key for root = ${sshkey}
		Network interfaces = ${interface}
		IPv4 address for ${interface} = ${ipaddr}
		Default IPv4 route = 10.0.1.1
		Setup a user = user
		Password for user = ${userpw}
		Public ssh key for user = ${sshkey}
		Allow root ssh login = yes
		What timezone are you in = Europe/Berlin
		Location of sets = http
		Server = ${setserver}
		Server directory = pub/OpenBSD/snapshots/${arch}
		Use http instead = yes
		Set name(s) = done
		Location of sets = http
		Server = ${siteserver}
		Server directory = site
		Use http instead = yes
		INSTALL.${arch} not found. Use sets found here anyway = yes
		Set name(s) = done
		Continue without verification = yes
	EOF
#		Which network interface do you wish to configure = ${interface}
#		Checksum test for site${version}.tgz failed. Continue anyway = yes
#		Unverified sets: site${version}.tgz. Continue without verification = yes
}

set_dhcpd_conf() {
	case "$1" in
		"on")
		action="host $machine { 			\
			hardware ethernet $hwaddr;		\
			fixed-address $ipaddr;			\
			next-server $tftpserver;		\
			filename \"${machine}/auto_install\";	\
		} #$machine"
		;;
		*)
		action="host $machine { 		\
			hardware ethernet $hwaddr;	\
			fixed-address $ipaddr;		\
			next-server $tftpserver;	\
			filename \"invalid\";		\
		} #$machine"
		;;
	esac

	temp_file=`mktemp`
	sed -e "s,^.*#$machine$,$action," /etc/dhcpd.conf > $temp_file
	cat $temp_file > /etc/dhcpd.conf
	rm -f $temp_file

	doas /etc/rc.d/dhcpd restart
}

on_exit() {
	set_dhcpd_conf off	> /dev/null
}

trap on_exit EXIT

tftp_dir="/var/spool/tftp/${machine}"

rm -rf ${tftp_dir}
mkdir -p ${tftp_dir}

# get current bsd.rd and pxeboot file
ftp -o /var/spool/tftp/bsd http://[2001:a60:91df:c000::16]/pub/OpenBSD/snapshots/${arch}/bsd.rd
ftp -o ${tftp_dir}/auto_install http://[2001:a60:91df:c000::16]/pub/OpenBSD/snapshots/${arch}/pxeboot

mkdir -p /var/www/htdocs/${machine}
mk_install_conf /var/www/htdocs/${machine}/install.conf

# generate random.seed file
#mkdir -p /var/spool/tftp/etc
#dd if=/dev/random of="/var/spool/tftp/etc/random.seed" bs=512 count=1 2>/dev/null

# set serial configuration for boot loader
cat - > /var/spool/tftp/etc/boot.conf <<-EOF
	stty com0 115200
	set tty com0
EOF

set_dhcpd_conf on	> /dev/null
ssh root@${ipaddr} shutdown -r now || power.sh cycle
# tftpd.expect
finish.expect
set_dhcpd_conf off	> /dev/null
login.expect
