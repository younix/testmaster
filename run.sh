#!/bin/sh

setenv="/usr/local/bin/envdir /home/$USER/env"
PATH="/home/test/bin:$PATH"

no_command() {
	echo "command is not configured for $USER"
	exit 1
}

command="$SSH_ORIGINAL_COMMAND"
set -- $command
action="$1"

case "$action" in
""|"console")
	exec /usr/local/bin/console "$USER"
	;;
"bsdcons")
	if ! test -f /home/consoles/$USER; then no_command; fi
	exec bsdcons.sh /home/consoles/$USER
	;;
"on"|"off"|"cycle"|"reset")
	if ! test -f /home/$USER/env/powerdevice; then no_command; fi
	if $setenv checklock.sh; then
		exec $setenv power.sh $action
	fi
	;;
"powerdown"|"powerup"|"reboot")
	if $setenv checklock.sh; then
		exec $setenv $action.sh
	fi
	;;
"install"|"upgrade"|"dhcp"|"linux")
	if ! test -f /home/$USER/env/install; then no_command; fi
	if $setenv checklock.sh; then
		shift
		exec $setenv setup.sh $action $*
	fi
	;;
"env")
	if $setenv checklock.sh; then
		exec $setenv env
	fi
	;;
"lock")
	exec $setenv lock.sh
	;;
"unlock")
	exec $setenv unlock.sh
	;;
"scp")
	case "$command" in
	"scp -t .")
		exec scp -t /var/spool/tftp/$USER
		;;
	"scp -r -t .")
		exec scp -r -t /var/spool/tftp/$USER
		;;
	esac
	;;
"info")
	exec $setenv info.sh
	;;
"help")
	echo "          - console"
	echo "powerup   - power up machine if not already running"
	echo "powerdown - shutdown machine gracefully, turn power off"
	echo "reboot    - reboot machine gracefully"
	if test -f /home/$USER/env/powerdevice; then
		echo "on        - power on"
		echo "off       - power off"
		echo "cycle     - power cycle"
		echo "reset     - power reset"
	fi
	if test -f /home/$USER/env/install; then
		echo "install   - install current snapshot"
		echo "upgrade   - upgrade to current snapshot"
		echo "dhcp      - boot with dhcp from tftp once"
	fi
	echo "bsdcons   - console message of previous OpenBSD boot"
	echo "env       - show environment"
	echo "lock      - lock access to machine"
	echo "unlock    - remove lock from machine"
	echo "info      - collect information on machine"
	echo "scp       - copy boot files to tftp server, use scp -O"
	echo "help      - print this message"
	;;
*)
	echo "unknown command";;
esac

exit 1
