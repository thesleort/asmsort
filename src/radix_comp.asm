.section .data
	all_memory:	.space 16000000	#holds 2n memory. capacity is 2000000 elements.
	buffer:		.space 2048
	file_stat:	.space 144	#Size of the fstat struct
	hello: 		.ascii "hello"
	one_byte: 	.ascii "h"

newline: .string "\n"

.section .bss
	.lcomm file_buffer, 100000000
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

	mov $10, %rax
	mov $all_memory, %r15			# %r15 points to the allocated memory. the allocated memory will be split in two lists of equal size
						# %r15 points to the first list
	mov %r15, %r13				# and %r14 points to the second list
	mov $0, %r14				# holds the offset of %r15
						# %r10 holds a number to be analyzed
	mov $1, %rsi				# holds a flag. this value is analyzed in every preparation step. the value decides whether
						# list one should be sorted or list two. if the value is 0, then list 2 should be sorted. if the value is 1, then list 1 should be sorted
	# %r8 holds the index to write to
	


	mov 16(%RSP),		%R8		# File to open
	xor %R12,			%R12
	mov $1,				%R13
	push	%RBP
	mov		%RSP,		%RBP

_open:
	mov $SYS_OPEN,			%RAX	# Open file
	mov %R8,			%RDI	# File descriptor
	xor %RSI,			%RSI	# Interrupt flag4
	syscall
	mov %RAX,			%R9


_initread:
	#Get File Size
	mov $5,				%RAX	# Syscall fstat
	mov %R9,			%RDI	# File Handler
	mov $file_stat,		%RSI	# Reserved space for the stat struct
	syscall

	mov $file_stat,		%RBX
	mov 48(%RBX),		%rdx	# Position of size in the struct

	mov $SYS_READ,		%RAX	# Read file
	mov %R9,		%RDI	# File descriptor from before
	mov $file_buffer,	%RSI	#
	syscall
	mov $file_buffer,	%R15
	xor %rcx,		%rcx

	xor %r10, %r10
	mov $0, %r10			# used as offset for all_memory
	xor %rbx, %rbx
	mov $all_memory, %rbx
	mov $0, %r11			# used for counting total list elements
	
	

_read:

	xor %rdx,			%rdx
	movb (%R15),			%dl		# dl is in rdx

	cmp $0,				%dl		# Ensure haven't read EOF
	je _final			# Stop reading file

	cmp $0xA,			%dl
	je _pts

	cmp $0,				%R13
	jne _add
	je _add2

_add:
	movzx %dl,			%R14
	sub $48,			%R14
	add %R14,			%R12
	xor %R13,			%R13
	inc %R15
	jmp _read

_add2:
	imul $10,			%R12
	movzx %dl,			%R14
	sub $48,			%R14
	add %R14,			%R12
	inc %R15
	jmp _read

_pts:							# TODO Put on stack/list instead of printing it.
	inc		%rcx
	movq %R12, (%rbx)
	add $8, %rbx

	inc %r11				# we count a number
	
	mov 	$1,			%R13
	inc 	%R15
	xor		%R12,		%R12
	jmp 	_read				# Read file again
	

_final:
	cmp 	$0,			%R12
	je 	_prepare_first_count
	inc 	%rcx
	inc %r11
	movq %R12, (%rbx)
	add $8, %rbx

	xor %R15,	%R15 			#Counter for comparisons/tests
	
	_prepare_first_count:
		movq $63, %rcx			#the number of times we need to shift the mask in total
		movq %r11, %rax			#we want %rax to hold the number of elements.
		movq $all_memory, %rdx		#holds the start of the first list
		movq %rdx, %rdi
		imul $8, %rdi
		add $all_memory, %rdi		#holds the start of the second list

		movq %rax, %r11			#used as a counter

		movq $1, %r12 			#holds the mask starting at 00...01

		movq %rdx, %r14			#reset offset

		movq %rdx, %r9			#holds the index of the first element with bit value 0 in a specific row
		jmp _count


	_count:
		inc %R15
		test %r11, %r11			#start sorting if all elements have been counted
		jz _prepare_sort		
		
		movq (%r14), %r10

		add $8, %r14			#go to the next index
		dec %r11			#decrement counter

		and %r12, %r10
		inc %R15
		test %r10, %r10			#if %r10 contains 0, the analyzed value must have been 0. thus, we need to count
		jz _count_0
		jmp _count			#else we need to count a 1
	

	_count_0:
		add $8, %r9			#count a 1
		jmp _count

	
	_prepare_sort:
		movq %rax, %r11			#reset counter
		inc %R15
		test %rsi, %rsi
		jnz _prepare_list_1_for_sort	#if zf==0 we need to prepare list 1
		

						#else we prepare list 2

	# list 2 sorts by writing to list 1
	_prepare_list_2_for_sort:
		movq %rdi, %r14
		movq %rdx, %r8
		subq %rdi, %r9			#HERHERHEHRHERHEHREHR
		addq %r8, %r9
		jmp _sort

	# list 1 sorts by writing to list 2
	_prepare_list_1_for_sort:			
		movq %rdx, %r14			#reset offset
		movq %rdi, %r8			#we need to write to the second list
		subq %rdx, %r9
		addq %r8, %r9			#thus, we also need to move the middle to the next list
		jmp _sort

	_sort:
		inc %R15
		test %r11, %r11			# have we analyzed all elements?
		jz _prepare_next_count

		dec %r11

		movq (%r14), %r10

		and %r12, %r10
		inc %R15
		test %r10, %r10
		jz _is_0
		jmp _is_1

	_is_1:
		movq (%r14), %r13
		movq %r13, (%r9)
		add $8, %r9
		add $8, %r14
		jmp _sort

	_is_0:
		movq (%r14), %r13
		movq %r13, (%r8)
		add $8, %r8
		add $8, %r14
		jmp _sort


	_prepare_next_count:
		
		movq %rax, %r11			#reset counter

		inc %R15
		test %rsi, %rsi
		jnz _prepare_list_2_for_count	# now we need to prepare the opposite list for counting
		jmp _prepare_list_1_for_count	# thus, we switch around the conditions


	_prepare_list_1_for_count:
	
		movq $1, %rsi			# we need to look at list 2 in the next iteration

		inc %R15
		test %rcx, %rcx
		jz _write
		
		dec %rcx
		
		shl $1, %r12			# shift mask one time to the left

		movq %rdx, %r14
		movq %rdx, %r9
		jmp _count
		
	_prepare_list_2_for_count:

		movq $0, %rsi			# we need to look at list 1 in the next iteration

		inc %R15
		test %rcx, %rcx
		jz _write
		
		dec %rcx
		
		shl $1, %r12			# shift mask one time to the left
				
		movq %rdi, %r14
		movq %rdi, %r9
		jmp _count


	_write:
		mov 	%R15,		%R10	
	    xor     %R12,       %R12    # Clear R12, which should hold an integer to be written
	    xor     %R15,       %R15    # Clear R15, for counting length of integer
	    mov     $10,        %R13    # DO NOT TOUCH! - Division by 10.
	    push 	%R10
	    

	_getnum:
	    xor     %R12,       %R12
	    pop     %R12
	    cmp     $0,      	%R12
	    je      _exit

	_convert:
	    inc     %R15                # Increase digit counter.
	    mov     %R12,       %RAX    # Move integer for div instruction.
	    xor     %rdx,       %rdx    # Set rdx to 0 for division.
	    div     %R13                # Execute the division.
	    add     $48,        %rdx    # rdx holds the remainder from division, and we add 48 to convert to ascii.
	    push    %rdx                # We push rdx to the stack so we can get digits out in correct order.
	    mov     %RAX,       %R12    # RAX holds the number after division has been executed, and we move it back into R12.
	    cmp     $0,         %R12    # if R12 is 0, we are done with this number and we can start printing it.
	    je      _print              # Print the number.
	    jmp     _convert            # Otherwise, keep converting the number to digits.

	_print:
	    pop     %R14
	    mov     $int_buffer,%R12
	    mov     %R14,       (%R12)
	    mov     $SYS_WRITE, %RAX
	    mov     $STDOUT,    %RDI
	    mov     %R12,       %RSI
	    mov     $1,         %rdx
	    syscall

	    dec     %R15
	    cmp     $0,         %R15
	    je      _newline             # End of integer
	    jmp     _print

	_newline:
	    mov $SYS_WRITE,		%RAX
	    mov $STDOUT,		%RDI
	    mov $newline,		%RSI
	    mov $1,				%rdx
	    syscall

	_exit:
	    mov $SYS_EXIT, 		%RAX	# Terminate program
	    mov $0,				%RDI
	    syscall
