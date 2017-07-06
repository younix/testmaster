#!/bin/sh

action="$SSH_ORIGINAL_COMMAND"
setenv="/usr/local/bin/envdir /home/$USER/env"
PATH="/home/test/bin:$PATH"

case "$action" in
	""|"console")
		exec /usr/local/bin/console "$USER"
		;;
	"on"|"off"|"cycle")
		exec $setenv power.sh $action
		;;
	"setup")
		exec $setenv setup.sh
		;;
	"upgrade")
		exec $setenv upgrade.sh
		;;
	"help")
		echo "       - console"
		echo "on     - power on"
		echo "off    - power off"
		echo "cycle  - power cycle"
		echo "setup  - install current snapshot"
		echo "update - update to current snapshot"
		echo "help   - print this message"
		;;
	*)
		echo "unknown command";;
esac
