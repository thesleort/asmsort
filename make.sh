#!/bin/sh
as *.asm -o your_sorter.o
ld your_sorter.o -o your_sorter
