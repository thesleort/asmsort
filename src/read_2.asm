.section .data
	buffer:		.space 2048
	file_stat:	.space 144	#Size of the fstat struct


newline: .string "\n"

.section .bss
	.lcomm file_buffer, 1000000
	.lcomm int_buffer, 8
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
	# Algorithm works on an abstract array with A[j] as lowest element and A[n] as greatest element and index i. Array is implemented using the stack. Each number takes up 8 byte spaces in the array.
	# Thus, to go from the number at index 1 to the number at index 2 we need to do A[index1+8] 
	
	jmp _start_quicksort

	mov 16(%RSP), 		%R8		# File to open
        xor %R12,               %R12
        mov $1,                 %R13

	push %rbp
	mov %rsp, %rbp

_open:
	mov $SYS_OPEN, 		%RAX		# Open file
	mov %R8, 		%RDI		# File descriptor
	mov $0, 		%RSI		# Interrupt flag
	syscall
	mov %RAX, 		%R9
	

_initread:
	#Get File Size
	mov $5,			%RAX			#Syscall fstat
	mov %R9,		%RDI	#File Handler
	mov $file_stat,		%RSI	#Reserved space for the stat struct
	syscall

	mov $file_stat, 	%RBX
	mov 48(%RBX),		%RDX	#Position of size in the struct

	mov $SYS_READ, 		%RAX		# Read file
	mov %R9, 		%RDI		# File descriptor from before
	mov $file_buffer, 	%RSI		# 
	syscall
	mov $file_buffer, 	%R15
	mov $-8, %r10				# %r10 Used for finding max index in the list. We increment this by 8 every time we count a number. Initial value is -8. This way we get a 0-indexed list
	

_read:

	xor %RDX, 		%RDX
	movb (%R15), 		%dl
	
	cmp $0,			%dl	# Ensure haven't read EOF
	je _push_last		# Stop reading file


        cmp $0xA,               %dl
	je _push		#_write

	cmp $0,			%R13
        jne _add

	cmp $0,			%R13
	je _add2



_add:
	movzx %dl,		%R14
        sub $48,                %R14
        add %R14,		%R12
	mov $0,			%R13
	inc %R15
        jmp _read

_add2:	
	imul $10,		%R12
	movzx %dl,		%R14	
        sub $48,                %R14
        add %R14,		%R12
	inc %R15
	jmp _read

_push: 
	push %r12
	mov $1,			%R13
	inc %R15
	add $8, %r10		#we count a number index
	
	jmp _read

_push_last: 
	push %r12
	mov $1,			%R13
	inc %R15
	add $8, %r10		#we count a number index
	
	jmp _start_quicksort


_write_3:
	mov $6, %r13

_write_2:	
	test %r13, %r13
	jz _exit
	mov $int_buffer, %r11
	pop (%r11)
	mov $SYS_WRITE,		%RAX		# Write
	mov $STDOUT, 		%RDI		# Standard output
	mov %r11,		%RSI
	mov $8, 		%RDX		
	syscall
	sub $1, %r13
	
	mov $SYS_WRITE,		%RAX
        mov $STDOUT,            %RDI
        mov $newline,           %RSI
        mov $2,                 %RDX
	syscall

	jmp _write_2
	


_start_quicksort:
	push %rbp
	mov %rsp, %rbp
	push $121   		
	push $122
	push $123
	push $124
	push $125
				#TODO change %r14 and %r15 to fit a varying number of list elements
	mov $-8, %r14		#initial value of minimum should be -8 (%rbp - 8 is the first index of the list since %rbp points to the old %rsp)
	mov $-40, %r15		#initial value of max. 
	#sub %r10, %r15		#%rsp = %rbp - k. because of the subtraction sign we use sub to get the value of max. this should work as max = %rbp + (-k)
	movq (%rbp, %r14), %mm1

	mov %r15, %r11					#initialize the counter. this should be equal to max - min. this is counted upwards from a negative value to zero
	sub %r14, %r11

	movq $-8, %r13
	movq $-40, %r12

	#call partition
	call quicksort
	
	jmp _write_3
		


# %r15 Used for finding max index in the list. We increment this by 8 every time we count a number. Initial value is -8. This way we get a 0-indexed list
# %r14 Holds min. This is also the index of the element we choose as >>>PIVOT<<<. In the first iteration our min should be index 0
# %r13 tells us where the border between numbers less than or equal to pivot and numbers greater than. Initial value of mid in each iteration should be equal to min. 
# %r12 holds the index i of a number we want to compare to. We want to compare the pivot to all elements between A[pivot+1]...A[max]. We jump 8 bytes each time, thus i=min+8 for each partition
# %r11 counts how many elements partition should iterate over. supposed to run as long as 0 < (%r11)=(%r15)-(%r14). note that this results in %r11 needing to be counted as 0 -> 8 -> 16 -> 24... 
# %mm1 holds the pivot

.type quicksort, @function
quicksort:	
	
	cmp %r14, %r15
	je return 				# if min is greater than or equal to max
	jg return		
	
	movq (%rbp, %r14), %mm1			# the pivot is the first element in the list and is kept in an mmx register
	mov %r15, %r12				# reset i
	mov %r14, %r13				# reset mid 		
			
	call partition				# after partition we want to call quicksort on the partioned lists: quicksort(min,i+8),quicksort(i-8,max)	
						# for the first iteration of quicksort we need to have min=min and max=i+8. we save i-8 and max to the stack so we later can use them for the second iteration of 							# quicksort. Note that i = mid after every partition
	
	push %r15				# push max	
	mov %r12, %r11
	sub $8, %r11	
	push %r11				# push i-8

	
	add $8, %r12				
	mov %r12, %r15				# new max = i+8

	mov %r15, %r11				#initialize the counter. this should be equal to max - min. this is counted upwards from a negative value to zero
	sub %r14, %r11
	
	call quicksort

	pop %r14				# min = i-8
	pop %r15				# max = old max from the stack

	mov %r15, %r11				#initialize the counter. this should be equal to max - min. this is counted upwards from a negative value to zero
	sub %r14, %r11

	call quicksort

	return:
	ret

.type partition, @function

partition:
	compare_loop:
	test %r11, %r11				#when %r15 = we have compared all objects
	jz done	#_write_3 #done


	movq (%rbp, %r12), %mm0
	psubq %mm1, %mm0			
	movq %mm0, %rax	
	test %rax, %rax				#sets sf==1 if (%mm0)<(%mm1) and zf==1 if (%mm0)==(%mm1)
	js less_or_equal			#if (%mm0)<(%mm1) or							
	jz less_or_equal			#if (%mm0)==(%mm1)

						#else (%mm0)>(%mm1)	
	greater:
	sub $8, %r13
	add $8, %r11
	movq (%rbp, %r12), %rsi
	movq (%rbp, %r13), %rdi
	movq %rdi, (%rbp, %r12)
	movq %rsi, (%rbp, %r13)
	jmp compare_loop 

	less_or_equal:
	add $8, %r12
	add $8, %r11
	jmp compare_loop					

	done:
	movq (%rbp, %r14), %rsi
	movq (%rbp, %r12), %rdi
	movq %rdi, (%rbp, %r14)
	movq %rsi, (%rbp, %r12)	

	ret
		

_exit:
	mov %rbp, %rsp
	pop %rbp

	mov $SYS_EXIT, 	%RAX		# Terminate program
	mov $0, %RDI
	syscall

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


