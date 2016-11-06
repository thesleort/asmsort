# Arg 1: speed file, Arg 2: comparison file

import sys


def mergeTests(file1, file2):
    spd_10 = []
    spd_100 = []
    spd_1000 = []
    spd_5000 = []
    spd_10000 = []
    spd_50000 = []
    spd_100000 = []
    spd_500000 = []
    spd_1000000 = []
    cmp_10 = []
    cmp_100 = []
    cmp_1000 = []
    cmp_5000 = []
    cmp_10000 = []
    cmp_50000 = []
    cmp_100000 = []
    cmp_500000 = []
    cmp_1000000 = []
    sizes = [10, 100, 1000, 5000, 10000, 50000, 100000, 500000, 1000000]
    with open(file1, "r") as f_in:
        for line in f_in:
            line = line.split()
            if len(line) == 2:
                current = line[1]
            else:
                locals()["spd_" + current].append(float(line[0]))
    with open(file2, "r") as f_in:
        for line in f_in:
            line = line.split()
            if len(line) == 2:
                current = line[1]
            else:
                locals()["cmp_" + current].append(float(line[0]))
    for size in sizes:
        print(str(size) + "_time:"),
        for el in locals()["spd_" + str(size)]:
            print("\t" + str(el)),
        print("\n" + str(size) + "_mcips:"),
        n = 0
        for el in locals()["cmp_" + str(size)]:
            try:
                print("\t" + str(round((el / locals()["spd_" + str(size)][n])/1000000, 2))),
            except ZeroDivisionError:
                print("\tN/A".rstrip()),
            n += 1
        print


mergeTests(sys.argv[1], sys.argv[2])
