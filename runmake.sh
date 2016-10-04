#!/bin/sh
as *.asm -o your_sorter.o
ld your_sorter.o -o your_sorter
# the parameter ($1) is the path to the file of unsorted numbers.
./your_sorter $1
