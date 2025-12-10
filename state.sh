#!/bin/sh

set -eu

/home/test/bin/snmp.sh > /var/www/obsdlab/state.css.tmp
mv /var/www/obsdlab/state.css.tmp /var/www/obsdlab/state.css
