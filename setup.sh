#!/bin/sh

set -eux

obsdmirror=[2a12:6900:1000:1000::6]
#obsdmirror=obsdmirror.genua.de
#obsdmirror=ftp.hostserver.de

usage() {
	cat >/dev/stderr <<EOF
setup.sh install|upgrade|dhcp [-b target] [-k kernel] [-r release]
    target	the name of the netboot file
    kernel	the name of the kernel file
    release	no snapshot, but release, like 6.3
		cannot be used with -b and -k
EOF
	exit 1
}

setup=$1
shift
case "$setup" in
install|upgrade|dhcp|linux)
	;;
*)
	usage
	;;
esac

release=snapshots
args=`getopt b:k:r: $*`
if [ $? -ne 0 ]; then
	usage
fi
set -- $args
while [ $# -ne 0 ]
do
	case "$1" in
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

if [ "$release" != "snapshots" -a -n "${target:-}" -a -n "${kernel:-}" ]; then
	usage
fi

PATH="/home/test/bin:$PATH"

echo "start $setup of snapshot or release on machine $machine"

mk_setup_conf() {
	rm -f ${1}

	cat > ${1} <<- EOF
		System hostname = ${machine}
		DNS domain name = obsd-lab.genua.de
		Password for root = ${rootpw:-toor}
		Public ssh key for root = ${sshkey:-}
		Network interfaces = ${interface}
		Network interface to configure = ${interface}
		IPv4 address for ${interface} = ${ipaddr}
		Default IPv4 route = 10.0.1.1
		$(if [ -n "${userpw:-}" ]; then
			echo "Setup a user = user";
			echo "Password for user = ${userpw}"
			echo "Public ssh key for user = ${sshkey:-}"
		fi)
		Allow root ssh login = yes
		What timezone are you in = Europe/Berlin
		Location of sets = http
		Server = ${setserver:-10.0.1.3}
		Server directory = pub/OpenBSD/${release}/${arch}
		Use http instead = yes
		Set name(s) = done
		$(if [ -n "${disk:-}" ]; then
			echo "Which disk is the root disk = ${disk}"
		fi)
		$(if [ -n "${partition:-}" ]; then
			echo "Use (W)hole disk MBR, whole disk (G)PT, (O)penBSD area = ${partition}"
		fi)
	EOF
	if [ "$setup" = "install" ]; then
		cat >> ${1} <<- EOF
		$(if [ -n "${siteserver:-}" ]; then
			echo "Location of sets = http"
			echo "Server = ${siteserver}"
			echo "Server directory = site"
			echo "Use http instead = yes"
			echo "INSTALL.${arch} not found. Use sets found here anyway = yes"
			echo "Set name(s) = done"
			echo "Continue without verification = yes"
		fi)
		EOF
	fi
}

set_dhcpd_conf() {

	set -eux

	case "$1" in
	"on")
		action="host $machine { \
hardware ethernet $hwaddr; \
fixed-address $ipaddr; \
next-server ${tftpserver:-10.0.1.1}; \
filename \"${2:-invalid}\"; \
option option-209 \"tftp://${tftpserver:-10.0.1.1}/config\"; \
} #$machine"
		;;
	*)
		action="host $machine { \
hardware ethernet $hwaddr; \
fixed-address $ipaddr; \
next-server ${tftpserver:-10.0.1.1}; \
filename \"invalid\"; \
} #$machine"
		;;
	esac

	flock /etc/dhcpd.conf ed /etc/dhcpd.conf <<-EOF
		H
		,s,^.*#$machine$,$action,
		wq
	EOF

	doas /etc/rc.d/dhcpd restart
}

on_exit() {
	set_dhcpd_conf off
}

trap on_exit EXIT

tftp_home="/var/spool/tftp"
tftp_dir="/var/spool/tftp/${machine}"
if [ "${netboot:-invalid}" != "invalid" ]; then
	netboot="${netboot}"
elif [ "$arch" = "amd64" ]; then
	netboot="pxeboot"
elif [ "$arch" = "arm64" ]; then
	netboot="BOOTAA64.EFI"
elif [ "$arch" = "armv7" ]; then
	netboot="BOOTARM.EFI"
elif [ "$arch" = "i386" ]; then
	netboot="pxeboot"
elif [ "$arch" = "octeon" ]; then
	netboot=""
	if [ -z "${target:-}" ]; then
		target="${kernel:-bsd.rd}"
	fi
elif [ "$arch" = "powerpc64" ]; then
	netboot=""
elif [ "$arch" = "riscv64" ]; then
	netboot="BOOTRISCV64.EFI"
elif [ "$arch" = "sparc64" ]; then
	netboot="ofwboot.net"
else
	unset netboot;
fi

cd ${tftp_home}
rm -f ${ipaddr} && ln -s ${machine} ${ipaddr}
mkdir -p -m 775 ${tftp_dir}
cd ${tftp_dir}
ftp "http://$obsdmirror/pub/OpenBSD/$release/$arch/SHA256.sig"
basekey="$(sed -n 's/.*verify with \(openbsd-[0-9]*-base.pub\).*/\1/p' \
    SHA256.sig)"

if [ -z "${target:-}" ]; then
	if [ -n "${netboot:-}" ]; then
		ftp "http://$obsdmirror/pub/OpenBSD/$release/$arch/$netboot"
		signify -C -p /etc/signify/$basekey -x SHA256.sig "$netboot"
	fi
	target="${netboot:-invalid}"
fi
ln -sf $target auto_$setup

if [ "$setup" == "dhcp" ]; then
	set_dhcpd_conf on auto_$setup
	power.sh cycle
	dhcpboot.expect
	set_dhcpd_conf off
	exit 0
fi

if [ "$setup" == "linux" ]; then
	cp -r $tftp_home/linux/* $tftp_dir
	set_dhcpd_conf on pxelinux.0
	power.sh cycle
	linuxboot.expect
	set_dhcpd_conf off
	exit 0
fi

if [ -z "${kernel:-}" ]; then
	ftp "http://$obsdmirror/pub/OpenBSD/$release/$arch/bsd.rd"
	signify -C -p /etc/signify/$basekey -x SHA256.sig bsd.rd
	kernel="bsd.rd"
fi

mkdir -p -m 775 ${tftp_dir}/etc

rm -f etc/boot.conf.tmp
if [ "$arch" = "i386" -o "$arch" = "amd64" ]; then
	# set serial configuration for boot loader
	echo stty ${com:-com0} ${comspeed:-115200} >>etc/boot.conf.tmp
	echo set tty ${com:-com0} >>etc/boot.conf.tmp
fi
echo set image $kernel >>etc/boot.conf.tmp
mv etc/boot.conf.tmp etc/boot.conf

rm -f etc/random.seed.tmp
dd if=/dev/random of=etc/random.seed.tmp bs=512 count=1 status=none
chmod 644 etc/random.seed.tmp
mv etc/random.seed.tmp etc/random.seed

mk_setup_conf /var/www/htdocs/${hwaddr}-${setup}.conf

set_dhcpd_conf on auto_$setup

if [ "$arch" = "sparc64" ]; then
	for i in 1 2; do
		timeout 60 ssh root@${ipaddr} shutdown -h now halt by \
		    testmaster || printf "\n\005c." | console -f $machine
		ofwprompt.expect && break

		# like reset on v440, might be necessary on other sparcs:
		#printf "\n\005cl0\005c." | console -f $machine
		#ofwprompt.expect && break

		printf "\n#.\n\005c." | console -f $machine
		if lomprompt.expect; then
			printf "\nreset -cxy\n\005c." | console -f $machine
			sleep 900 # v440 checks after reset take about 10 min
			printf "\n\005c." | console -f $machine
			ofwprompt.expect && break
		fi

		power.sh on
		if login.expect; then
			printf "admin\nadmin\n\005c." | console -f $machine;
		fi

		printf "\n\005c." | console -f $machine
		ofwprompt.expect && break
		false
	done
	# serial console eats characters at this point, firmware bug?
	{
	    echo -n "boot net:"; sleep 1;
	    echo -n "rarp $kernel"; sleep 1;
	    printf "\n\005c."; sleep 1;
	} | console -f $machine
else
	timeout 60 ssh root@${ipaddr} shutdown -r now reboot by testmaster ||
	    power.sh cycle
fi

finish.expect
set_dhcpd_conf off
if [ "$arch" = "sparc64" ]; then
	if ofwprompt.expect; then
		printf "boot disk\n\005c." | console -f $machine
	fi
fi

if ! login.expect; then
	echo "no login prompt on machine $machine, send two newline"
	printf "\n\005c." | console -f $machine
	sleep 1
	printf "\n\005c." | console -f $machine
	sleep 1
	tail -n 16 "/home/consoles/$machine" | grep '^login: '
fi
