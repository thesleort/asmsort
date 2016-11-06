# Creates a file with comparison information for use in mergeTests.py
# Arg1: path to sorting binary (which should only output number of comparisons)
# Arg2: path to data folder

import subprocess
import sys


def testComparisons(binary, dataPath):
    _10 = []
    _100 = []
    _1000 = []
    _5000 = []
    _10000 = []
    _50000 = []
    _100000 = []
    _500000 = []
    _1000000 = []
    sizes = [10, 100, 1000, 5000, 10000, 50000, 100000, 500000, 1000000]
    for size in sizes:
        for n in range(0, 20):
            filename = dataPath + "{0}_{1}.dat".format(size, n)
            cmd = [binary, filename]
            process = subprocess.Popen(cmd, stdout=subprocess.PIPE)
            process.wait()
            with open("out_time", "r") as time:
                for line in process.stdout:
                    locals()["_" + str(size)].append(line.strip("\n"))
    for size in sizes:
        print("Size: " + str(size))
        for el in locals()["_" + str(size)]:
            print(el)


testComparisons(sys.argv[1], sys.argv[2])
