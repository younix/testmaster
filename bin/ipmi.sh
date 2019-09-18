set -eu

host=$1
user=$2
pass=$3
driver=$4
status=$5
action=

if [ -z "$host" -o -z "$user" -o -z "$pass" -o -z "$driver" ]; then
	echo "insufficient settings"
	exit 1
fi

if [ ${status} -lt 0 -o ${status} -gt 1 ]; then
	echo "unkown status: ${status}"
	exit 1
fi

case "${status}" in
	"0")
	echo "power off, machine ${machine:--}"
	action="--off"
	;;

	"1")
	echo "power on, machine ${machine:--}"
	action="--on"
	;;
esac

ipmipower -h ${host} -u ${user} -p ${pass} -D ${driver} ${action} > /dev/null
