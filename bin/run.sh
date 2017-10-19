#!/bin/sh

action="$SSH_ORIGINAL_COMMAND"
setenv="/usr/local/bin/envdir /home/$USER/env"
PATH="/home/test/bin:$PATH"

function no_command {
	echo "command is not configured for $USER"
	exit 1
}

case "$action" in
	""|"console")
		exec /usr/local/bin/console "$USER"
		;;
	"on"|"off"|"cycle")
		if ! test -f /home/$USER/env/powerdevice; then no_command; fi
		if $setenv checklock.sh; then
			exec $setenv power.sh $action
		fi
		;;
	"reboot")
		if $setenv checklock.sh; then
			exec $setenv reboot.sh
		fi
		;;
	"setup"|"install")
		if ! test -f /home/$USER/env/install; then no_command; fi
		if $setenv checklock.sh; then
			exec $setenv install.sh
		fi
		;;
	"upgrade")
		if ! test -f /home/$USER/env/install; then no_command; fi
		if $setenv checklock.sh; then
			exec $setenv upgrade.sh
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
	"free")
		exec $setenv free.sh
		;;
	"scp -t .")
		exec scp -t /var/spool/tftp/$USER
		;;
	"scp -r -t .")
		exec scp -r -t /var/spool/tftp/$USER
		;;
	"help")
		echo "        - console"
		if test -f /home/$USER/env/powerdevice; then
			echo "on      - power on"
			echo "off     - power off"
			echo "cycle   - power cycle"
		fi
		if test -f /home/$USER/env/install; then
			echo "install - install current snapshot"
			echo "upgrade - upgrade to current snapshot"
		fi
		echo "lock    - lock access to machine"
		echo "free    - free access to machine"
		echo "help    - print this message"
		;;
	*)
		echo "unknown command";;
esac

exit 1
