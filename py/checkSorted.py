# This Python script checks if a file of integers are sorted (ascending or descending order).
# Integers should be separated with linebreaks and nothing else.
# Run using "python checkSorted.py {filename}" with the actual filename and no brackets.
import sys


def check_sorted_asc(filename):
    with open(filename, 'r') as fin:
        prev = -sys.maxsize - 1
        for l in fin:
            l.rstrip()
            if int(l) < prev:
                return False
            prev = int(l)
        return True


def check_sorted_des(filename):
    with open(filename, 'r') as fin:
        prev = sys.maxsize
        for l in fin:
            l.rstrip()
            if int(l) > prev:
                return False
            prev = int(l)
        return True


def check_sorted(filename):
    if check_sorted_asc(filename):
        print(filename + " is sorted in ascending order.")
    elif check_sorted_des(filename):
        print(filename + " is sorted in descending order.")
    else:
        print(filename + " is not sorted in ascending or descending order.")


check_sorted(sys.argv[1])
