#!/bin/sh

set -eu

dir=/home/$1

mkdir -p $dir/files
mkdir -p $dir/env
mkdir -p $dir/tftp
