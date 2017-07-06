set -eu

gude="10.0.1.15"
dev="gude"
port=${1}
status=${2}

if [ $port -lt 1 -o $port -gt 8 ]; then
	echo "unkown port numer: ${port}"
	exit 1
fi

if [ ${status} -lt 0 -o ${status} -gt 1 ]; then
	echo "unkown status: ${status}"
	exit 1
fi

case "${status}" in
	"0")
	echo "power off, machine ${machine:--}, dev $dev, port $port"
	;;

	"1")
	echo "power on, machine ${machine:--}, dev $dev, port $port"
	;;
esac

curl -s "http://${gude}/ov.html?cmd=1&p=${port}&s=${status}" > /dev/null
