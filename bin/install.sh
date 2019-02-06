#!/bin/sh

set -eux

usage() {
	echo "install [-b target] [-k kernel] [-r release]" > /dev/stderr
	echo "    target     the name of the netboot file" > /dev/stderr
	echo "    kernel     the name of the kernel file" > /dev/stderr
	echo "    release    no snapshot, but release, like 6.3" > /dev/stderr
	echo "               cannot be used with -b and -k" > /dev/stderr
	exit 1
}

release=snapshots
target=""
kernel=""
args=`getopt b:k:r: $*`
if [ $? -ne 0 ]; then
	usage
fi
set -- $args
while [ $# -ne 0 ]
do
	case "$1"
	in
		-b)
			target="$2";
			if echo "$target" | \
				! grep -q '^[0-9A-Za-z][0-9A-Za-z._-]*$'; then
				usage
			fi
			shift; shift;;
		-k)
			kernel="$2";
			if echo "$kernel" | \
				! grep -q '^[0-9A-Za-z][0-9A-Za-z._-]*$'; then
				usage
			fi
			shift; shift;;
		-r)
			release="$2";
			if echo "$release" | ! grep -q '^[0-9]\.[0-9]$'; then
				usage
			fi
			shift; shift;;
		--)
			shift; break;;
	esac
done

if [ "$release" != "snapshots" -a -n "$target" -a -n "$kernel" ]; then
	usage
fi

PATH="/home/test/bin:$PATH"

echo "start installation of snapshot or release on machine $machine"

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
$(if [ -n "${disk:-}" ]; then
	echo "Which disk is the root disk = ${disk}";
fi)
		What timezone are you in = Europe/Berlin
		Location of sets = http
		Server = ${setserver}
		Server directory = pub/OpenBSD/${release}/${arch}
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

	set -eux

	case "$1" in
		"on")
		action="host $machine { 		\
			hardware ethernet $hwaddr;	\
			fixed-address $ipaddr;		\
			next-server $tftpserver;	\
			filename \"auto_install\";	\
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
if [ "$arch" = "armv7" ]; then
	netboot="BOOTARM.EFI"
elif [ "$arch" = "arm64" ]; then
	netboot="BOOTAA64.EFI"
elif [ "$arch" = "sparc64" ]; then
	netboot="ofwboot.net"
else # default x86
	netboot="pxeboot"
fi

mkdir -p /var/www/htdocs/${machine}
mk_install_conf /var/www/htdocs/${hwaddr}-install.conf

mkdir -p ${tftp_dir}
rm -f ${tftp_dir}/invalid

if [ -s "${tftp_dir}/${target:-invalid}" ]; then
	cp "${tftp_dir}/${target:-invalid}" "${tftp_dir}/auto_install"
else
	ftp -o ${tftp_dir}/auto_install http://[2001:a60:91df:c000::16]/pub/OpenBSD/${release}/${arch}/${netboot}
fi

if [ -n "$kernel" -a -s "${tftp_dir}/${kernel}" ]; then
	cp "${tftp_dir}/${kernel}" "${tftp_dir}/bsd"
else
	ftp -o ${tftp_dir}/bsd http://[2001:a60:91df:c000::16]/pub/OpenBSD/${release}/${arch}/bsd.rd
fi

# generate random.seed file
mkdir -p ${tftp_dir}/etc -m 775
tmprand=`mktemp -p ${tftp_dir}/etc random.seed.XXXXXXXXXX`
dd if=/dev/random of=$tmprand bs=512 count=1 status=none
chmod 644 $tmprand
mv $tmprand ${tftp_dir}/etc/random.seed

if [ "$arch" = "i386" -o "$arch" = "amd64" ]; then
	# set serial configuration for boot loader
	cat - > ${tftp_dir}/etc/boot.conf <<-EOF
		stty com0 115200
		set tty com0
	EOF
fi

set_dhcpd_conf on	> /dev/null

if [ "$arch" = "sparc64" ]; then
	printf "\n#.\nset bootmode forth\nreset\n\005c." | console -f $machine

	ofwprompt.expect
	(printf "setenv auto-boot? false\n"; sleep 1;
	 printf "setenv boot-device net\n"; sleep 1;
	 printf "reset\n\005c.") | console -f $machine

	ofwprompt.expect
	printf "reset\n\005c." | console -f $machine

	ofwprompt.expect
	printf "boot net\n\005c." | console -f $machine
else
	ssh root@${ipaddr} shutdown -r now || power.sh cycle
fi

finish.expect
set_dhcpd_conf off	> /dev/null
login.expect
