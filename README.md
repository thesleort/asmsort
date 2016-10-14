# asmsort
A number sorter made in intel x86 using AT&amp;T assembly language.

#Compiling and testing the program
**Compile**<br/>
To compile the program, simply run the following shell script in the Linux terminal.
```
sh make.sh
```
**Run**<br/>
To run the program, simply run
```
./your_sorter test.dat
```
**Combined**<br/>
It is also possible to compile and run the program in one execution. This can be done using `runmake.sh`, which combines compiling and running in one script.
```
sh runmake.sh test.dat
```
#Generate test file
To generate a test file, simply run `randomgen.sh` with a number-parameter to tell how many random numbers the test file should have.
```
bash randomgen.sh
```
_Please note that it is important to run this script using the `bash` command and not `sh`._
#Useful links
**Intel x86 official documentation**<br/>
https://software.intel.com/en-us/articles/introduction-to-x64-assembly <br/><br/>
**Linux System Calls x86_64 (Syscalls)**<br/>
http://blog.rchapman.org/posts/Linux_System_Call_Table_for_x86_64/ <br/><br/>
**Intel & AT&T syntax differences** <br/>
http://www.imada.sdu.dk/~kslarsen/Courses/dm546-2014-spring/Litteratur/IntelnATT.htm <br/><br/>
**Richard's Website** <br/>
http://imada.sdu.dk/~roettger/teaching/2016_fall_dm548.php<br/><br/>
**Simple tutorial**<br/>
http://asm.poly.ro/0x4553-Asm_tutor.html
