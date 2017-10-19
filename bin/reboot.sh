#!/bin/sh

set -eux

PATH="/home/test/bin:$PATH"

echo "reboot machine $machine"

ssh root@${ipaddr} shutdown -r now || power.sh cycle
login.expect
