#!/bin/sh
#Creates a test file, with a user specified amount of random numbers.
for i in {1..$1}; do echo $RANDOM; done > test.dat
