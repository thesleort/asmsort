#!/bin/sh
#Creates a test file, with a user specified amount of random numbers.
max=$(($1+0))
echo $max
for((i=1;i<=$1;i++)) 
	do echo $RANDOM 
	done > test.dat
