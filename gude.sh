set -eu

gude1="10.0.1.15"
gude2="10.0.1.16"

dev=$1
port=$2
status=$3

if [ $dev -lt 1 -o $dev -gt 2 ]; then
	echo "unkown dev numer: ${dev}"
	exit 1
fi

eval gude=\${gude${dev}}

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
