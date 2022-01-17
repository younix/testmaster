#!/bin/sh

set -eux

rm -f /dev/ttyc* /dev/cuac*

off=0

for card in 0 32 64; do
	for U in `jot 8 $off`; do
		minor=$(( $U + $card + $off ))
		mknod /dev/ttyc$U c 38 $minor

		minor=$(( $minor + 128 ))
		mknod /dev/cuac$U c 38 $minor
	done
	off=$(( $off + 8 ))
done

chmod 660 /dev/ttyc* /dev/cuac*
chown root:dialer /dev/ttyc* /dev/cuac*
