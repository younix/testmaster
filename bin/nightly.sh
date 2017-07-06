#!/bin/sh

set -eu

getsnap.sh
boot test
testrun test get_source
