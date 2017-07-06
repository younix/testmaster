#!/bin/sh

set -eux

PATH="/home/test/bin:$PATH"
tftpserver=10.0.1.4
setserver=10.0.1.5
siteserver=10.0.1.4
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
		Server directory = pub/OpenBSD/snapshots/i386
		Use http instead = yes
		Set name(s) = done
		Location of sets = http
		Server = ${siteserver}
		Server directory = site
		Use http instead = yes
		INSTALL.i386 not found. Use sets found here anyway = yes
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
		action="host $machine { 		\
			hardware ethernet $hwaddr;	\
			fixed-address $ipaddr;		\
			filename \"auto_install\";	\
			next-server $tftpserver;	\
		} #$machine"
		;;
		*)
		action="host $machine { 		\
			hardware ethernet $hwaddr;	\
			fixed-address $ipaddr;		\
		} #$machine"
		;;
	esac

	temp_file=`mktemp`
	sed -e "s/^.*#$machine$/$action/" /etc/dhcpd.conf > $temp_file
	cat $temp_file > /etc/dhcpd.conf
	rm -f $temp_file

	doas /etc/rc.d/dhcpd restart
}

on_exit() {
	set_dhcpd_conf off	> /dev/null
}

trap on_exit EXIT

# get current bsd.rd and pxeboot file
rm -f /var/spool/tftp/bsd
ftp -o /var/spool/tftp/bsd.rd  http://[2001:a60:91df:c000::16]/pub/OpenBSD/snapshots/i386/bsd.rd
ftp -o /var/spool/tftp/pxeboot http://[2001:a60:91df:c000::16]/pub/OpenBSD/snapshots/i386/pxeboot

cp /var/spool/tftp/bsd.rd /var/spool/tftp/bsd
cp /var/spool/tftp/pxeboot /var/spool/tftp/auto_install
mk_install_conf /var/www/htdocs/${hwaddr}-install.conf

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
