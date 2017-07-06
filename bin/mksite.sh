#!/bin/sh

set -eux

dir="/home/${machine}/site/"
dest="/home/${machine}/files/"

if [ ! -d "$dir" ]; then
	echo "there is no site directory: $dir" > /dev/stderr
	exit 1
fi

if [ ! -d "$dest" ]; then
	echo "there is no destination directory: $dest" > /dev/stderr
	exit 1
fi

cd $dir

tar -czp -f ${dest}/site${version}.tgz *
