your_sorter: read.o
	ld read.o -o your_sorter

asmsort.o: asmsort.asm
	as asmsort.asm -o asmsort.o

read.o: read.asm
	as read.asm -o read.o

stringtoint.o: stringtoint.asm
	as stringtoint.asm -o stringtoint.o

clean:
	rm *.o
