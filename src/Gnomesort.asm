
.section .data

.section bss

.set SYS_READ, 	0
.set SYS_WRITE, 1
.set SYS_OPEN, 	2
.set SYS_EXIT,	60
.set STDOUT, 	1

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
	je _exit						# Stop reading file

_push:	
	add $8, %r15				# count a number					
	mov $file_buffer, %rax			# TODO change the eight bytes reservation per number to four bytes when changing from %rax to %eax		
	call string_to_int			# transforms from strings to integers before pushing
	push %rax	
	jmp _read	


_exit:
	mov $SYS_EXIT, 		%RAX		# Terminate program
	mov $0, 			%RDI
	syscall


_sort:

        mov 8(%rbp), %rsi
        mov 12(%rbp), %rcx
        mov $0, %rax
        
mainloop:

		#If i = 0 move to the next element of the list
        cmp %rax, $0
        je increasecounter

        #If list[i-1] <= list[i] they are sorted, so we go to next element
        mov %rsi, %rbx
        mov -8(%rsi), %rdx
        cmp %rbx, %rdx
        jle increacecounter

        #Else the values will be swapped
        push %rsi
        push -8(%rsi)

        pop %rsi
        pop -8(%rsi)

        #Go to the previous element in the list and decrease i
        sub 8, %rsi
        dec %rax

        #Loop back to the top
        backtomain:
        	jmp mainloop

#Moving to the next element and increasing the counter
increasecounter:
        inc %rax
        add 8, %rsi
        jmp backtomain

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

