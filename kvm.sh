#!/bin/sh

set -eu

action="$1"

export LIBVIRT_DEFAULT_URI="qemu+ssh://${machine}@${vmhost}/system"

case "$action" in
0)
	command="destroy"
	;;
1)
	command="start"
	;;
2)
	command="reset"
	;;
*)
	echo "kvm unkown action: $action"
	exit 1
	;;
esac

echo "kvm $command, machine $machine on vmhost $vmhost"
virsh "$command" "$machine"
