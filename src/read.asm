.section .data
	buffer: .space 2048

newline: .string "\n"

.section .bss
	.lcomm file_buffer, 2048

.set SYS_READ, 	0
.set SYS_WRITE, 1
.set SYS_OPEN, 	2
.set SYS_EXIT,	60
.set STDOUT, 	1


#TODO change all "cmp" to "test" to increase speed
#TODO pop all stack elements, transform them into strings and print them

.section .text
.globl _start
_start:
	mov 16(%RSP), 		%R8			# File to open 
	mov $16, %r13					# holds the amount of times we should shift our bit-value. this is equal to n-1 where n is the maximum amount of bits, i.e. log2(99999) because of the 								# roof of five decimals. We to decrement the value of %r13 each time we want to test a new column of bits
	mov $17, %r14					# holds the maximum amount of bits needed for a decimal number. This value is reset to 17 each time we want to test a new column of bits	
	sub %r13, %r14

	mov $0, %r15					# holds the amount of total bytes needed. Used for counting exactly how many elements we need to sort. this number is equal to 8*n where n is the amount of 								# total numbers

	mov $-8, %r12					# Points to the current place in the stack where a number with current bit value of 0 can be inserted. Used as offset for %rsp. Base case is that we only 								# found one number of such criteria meaning that we only move eight bytes once. This number should be inserted in the exact spot that %rsp points to; thus 								# the starting value of $-8
	mov $0, %r10					# Points to the current place in the stack where a number with current bit value of 1 can be inserted. Used as offset for %rbp. Base case i that we dont 								# need to displace %rbp, thus the starting value of $0



_open:
	mov $SYS_OPEN, 		%RAX		# Open file
	mov %R8, 			%RDI		# File descriptor
	mov $0, 			%RSI		# Interrupt flag
	syscall
	mov %RAX, 			%R9
	
_read:
	mov $SYS_READ, 		%RAX		# Read file
	mov %R9, 			%RDI		# File descriptor from before
	mov $file_buffer, 	%RSI		# 
	mov $5, 			%RDX		# Read one char at a time
	syscall
	cmp $0, 			%RAX		# Ensure haven't read EOF
	je _sort					# Stop reading file


						
_push:	
	add $8, %r15				# count a number					
	mov $file_buffer, %rax			# TODO change the eight bytes reservation per number to four bytes when changing from %rax to %eax		
	call string_to_int			# transforms from strings to integers before pushing
	push %rax	
	mov %rax, %r11				# TODO change immediate $1 to register %r14 in shr
	shr $1, %r11				# explanation follows below
	jb _count_r12_read			# TODO change from %rax to %eax to halve the bit use
	jmp _read				# Read file again

# shr $1, %r11 shifts the binary value of %r11 one time to the right. The value that overflows is contained in the flag CF (carry flag). jb jumps if CF==1 and otherwise does not. This way we can discern between 0 and 1 bit-values
	

#special version of _count_r12. this is necessary for controlling the execution flow. it saves time to do the first wave of counting while we push all elements to the stack. con is that we increase the complexity
_count_r12_read:				# increments the count by 64 bits; move to the next number in the stack
	add $8, %r12
	jmp _read				

_count_r12:
	add $8, %r12
	jmp _count_row

_count_row:
	test %r9, %r9
	jz _sort_row
	mov (%rsp, %r9), %r11
	sub $8, %r9
	shr $1, %r11				#TODO make the code work with %r14 instead of $1
	jb _count_r12
	jmp _count_row
	

#sorts a list of numbers by sorting all rows of their bits
_sort:
	cmp $-2, %r13				# in the last shift we need to shift the 17 bits 18 times to the right such that the most significant bit will be in cf. thus, the last iteration should be when 							# %r13==-1 because then %r14 - %r13 = 17 - (-1) = 18. when %r13==-2 the sorting is done and the program should terminate
	je _exit
	mov %r15, %r9				#store the number of total amount of bytes in %r16 so we can change it temporarily without losing the value
	mov $0, %r12				#clear %r12 so it can hold a count for a new row	
	mov $0, %r10				#same as above	
	jmp _count_row
		
#sorts the numbers based on their bit values in a certain row
_sort_row:	
	test %r9, %r9				# tries to unify %r15 with itself. sets zf to 1 iff %r15 contains a value of 0. if zf==1 we have sorted all elements
	jz _sort				# jz jumps if zf==1. we want to sort the next row of bits, thus we return to the main sorting function _sort
	sub $8, %r9	
	mov (%rbp,%r10), %rax			# moves the current element of the stack into %rax to be analyzed. the current element is found by offsetting %rbp with the pointer %r10
	shr $1, %rax				# TODO make shr work with the value of %r14 instead of $1
	jb _bit_is_1
	jmp _bit_is_0
	

#if current bit is 1, the number is in correct place and we only need to decrement the pointer %r10 so that it points to the next number
_bit_is_1:
	sub $8, %r10
	jmp _sort_row


#if current bit is 0 we must put the number it belongs to (lets call it nmbr) further down in the stack (towards memory address 0). the number should be moved to (%rsp,%r12). however, this address already #contains a value. therefore, we swap the values (%rbp, %r10) and (%rsp,%r12). we now know that the nmbr is in its correct place. the new value of (%rbp, %r10) is now a number we have not analyzed yet.
#we should analyze this number and proceed until we know all numbers have been checked. %r12 should be incremented by 8 such that it points to place where the next number with bit value 1 should be
_bit_is_0:
	xchg (%rbp, %r10), (%rsp,%r12)
	add $8, %r12
	jmp _sort_row



_exit:
	mov $SYS_EXIT, 		%RAX		# Terminate program
	mov $0, 			%RDI
	syscall

.type count_r12, @function
count_r12:
	add $1, %r12
	ret

#string_to_int function borrowed from the solution to lab exercise 3
.type string_to_int, @function
string_to_int:
  /* Converts a string to an integer. Returns the integer in %rax.
   * %rax: Address of string to convert.
   */
 
  push %rbp
  mov %rsp, %rbp
 
  push %rbx
  push %rcx
  push %r8
 
  mov %rax, %r8
 
  xor %rax, %rax
  convertloop:
    movzx (%r8), %rbx     # moves a single character from the string in memory to %rbx
    cmp $48, %rbx         # If the character is anything less than ascii number 48, then we 					have reached the end.
  jl convertdone
    mov $10, %rcx
    mul %rcx              # mult multiplies %rax with the given operand and saves the result 					in %rdx:%rax.
                          # I multiply by 10 to shift the number one placement to the right to 					add the newest integer.
    sub $48, %rbx         # In ascii, numbers start at 0 = 48, 1 = 49, 2 = 50 and so on. So I 					subtract 48 to get the digit.
    add %rbx, %rax        # I add the newly read digit to our final integer.
    inc %r8               # Increment the pointer to get the next character.
  jmp convertloop
  convertdone:
 
  pop %r8
  pop %rcx
  pop %rbx
 
  mov %rbp, %rsp
  pop %rbp
  ret

