#!/bin/sh

# This tool should detects new snapshots of
# different architektures and downloads them.

set -eu

LOCK="${HOME}/lock/get_snapshot"
MIRROR="http://openbsd.cs.fau.de/pub/OpenBSD"
ARCH_LIST="i386 amd64 sparc64"
VERSION=57
DEST_DIR="/var/www/htdocs/pub/OpenBSD"
SNAP_TMP=`mktemp -d`

if [ ! -f "$LOCK" ]; then
	touch $LOCK
else
	echo "is locked" > /dev/stderr
	exit 1	
fi

cleanup() {
	rm -rf $LOCK $SNAP_TMP
}

trap cleanup EXIT

TGZ_LIST="base"
TGZ_LIST="${TGZ_LIST} comp"
TGZ_LIST="${TGZ_LIST} man"
TGZ_LIST="${TGZ_LIST} game"
TGZ_LIST="${TGZ_LIST} xshare xserv xfont xbase"

FILE_LIST="pxeboot bsd.rd"

fetch_files() {
	ARCH=$1
	dest="${DEST_DIR}/snapshots/${ARCH}/"
	filelist="/home/test/env/${ARCH}-files"
	mkdir -p $dest

	for file in `cat $filelist`; do
		url=${MIRROR}/snapshots/${ARCH}/$file
		ftp -o $dest/$file $url
	done
}

for ARCH in ${ARCH_LIST}; do
	URL=${MIRROR}/snapshots/${ARCH}/index.txt
	INDEX="${DEST_DIR}/snapshots/${ARCH}/index.txt"
	INDEX_TMP="${SNAP_TMP}/index.txt"

	#rm $INDEX
	ftp -o ${INDEX_TMP} ${URL}

	if cmp -s "${INDEX}" "${INDEX_TMP}" ; then
		echo "$ARCH is uptodate"
	else
		echo "download $ARCH"
		fetch_files $ARCH
		cp "${INDEX_TMP}" "${INDEX}"
	fi
done

