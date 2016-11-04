# Test each .dat file in dataPath directory using "time"
# Output of each dat file should be tested with "checkSorted.py"
#
import os
import sys
import subprocess
import math


def testBinary(binary, dataPath, compareScriptPath):
    allSorted = True
    for filename in os.listdir(dataPath):
        if filename.endswith(".dat"):
            s = "Testing " + binary + " with data file: " + filename
            print("\n")
            print("+" + "-" * 78 + "+")
            print("|" + " " * int(math.floor((78 - len(s)) / 2.0)) + s + " " * int(math.ceil((78 - len(s)) / 2.0)) + "|")
            print("+" + "-" * 78 + "+")
            format_string = " Time elapsed in seconds:\\n Real: %e \\n System: %S \\n User: %U \\n " \
                            "CPU percentage dedicated to task: %P"
            cmd = ["time", "-o", "out_time", "-f", format_string, binary, dataPath + filename]
            filename_noext = filename[:-4]
            f = open(filename_noext, "w")
            process = subprocess.Popen(cmd, stdout=f)
            process.wait()
            f.close()
            fo = open("out_time", "r")
            for line in fo:
                line = line.strip("\n")
                print("|" + line + " " * (78 - len(line)) + "|")
            print("+" + "-" * 78 + "+")
            fo.close()
            cmd = ["python", compareScriptPath, filename_noext]
            process = subprocess.Popen(cmd, stdout=subprocess.PIPE)
            process.wait()
            os.remove(filename_noext)
            s = "Output from checkSorted.py:"
            print("| " + s + " " * (77-len(s)) + "|")
            for line in process.stdout:
                line = line.strip("\n")
                print("| " + line + " " * (77 - len(line)) + "|")
            print("+" + "-" * 78 + "+")


testBinary(sys.argv[1], sys.argv[2], sys.argv[3])
