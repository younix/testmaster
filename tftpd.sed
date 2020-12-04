#!/usr/bin/sed -nuf

# input : 10.0.1.25 read test.txt
# output: 10.0.1.25/test.txt

s/\([^ ]*\) read \(.*\)$/\1\/\2/p
