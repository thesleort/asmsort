from random import randint

testSizes = [10, 100, 1000, 5000, 10000, 50000, 100000, 500000, 1000000]

for testSize in testSizes:

    for i in range(0, 5):
        fileName = "../data/" + str(testSize) + "_" + str(i) + ".dat"
        print(fileName)
        with open(fileName, "w") as f_out:
            for j in range(0, testSize):
                f_out.write(str(randint(0, 2**63-1)))
                if j != testSize-1:
                    f_out.write("\n")
