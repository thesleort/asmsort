import os
import subprocess
import sys


def testSpeed(binary, dataPath):
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
            format_string = "%e"
            cmd = ["time", "-o", "out_time", "-f", format_string, binary, filename]
            f = open("tmp", "w")
            process = subprocess.Popen(cmd, stdout=f)
            f.close()
            os.remove("tmp")
            process.wait()
            with open("out_time", "r") as time:
                for line in time:
                    locals()["_" + str(size)].append(line.strip("\n"))
    for size in sizes:
        print("Size: " + str(size))
        for el in locals()["_" + str(size)]:
            print(el)


testSpeed(sys.argv[1], sys.argv[2])
