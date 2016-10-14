#!/bin/sh
#Creates a test file, with a user specified amount of random numbers.
echo > test.dat
for i in {1..$1}; do echo $RANDOM; done >> test.dat
