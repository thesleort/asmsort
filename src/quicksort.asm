.section .data
	buffer:		.space 2048
	file_stat:	.space 144	#Size of the fstat struct

newline: .string "\n"

.section .bss
	.lcomm file_buffer, 80000000
	.lcomm int_buffer, 8

.set SYS_READ, 	0
.set SYS_WRITE, 1
.set SYS_OPEN, 	2
.set SYS_EXIT,	60
.set STDOUT, 	1



.section .text
.globl _start
_start:
	mov 16(%RSP),		%R8		# File to open
	xor %R12,			%R12
	mov $1,				%R13
	push	%RBP
	mov		%RSP,		%RBP

_open:
	mov $SYS_OPEN,		%RAX	# Open file
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
	mov %R9,			%RDI	# File descriptor from before
	mov $file_buffer,	%RSI	#
	syscall
	mov $file_buffer,	%R15
	xor %rcx,			%rcx

_read:

	xor %rdx,			%rdx
	movb (%R15),		%dl		# dl is in rdx

	cmp $0,				%dl		# Ensure haven't read EOF
	je _final		# Stop reading file

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
	push	%R12

	mov 	$1,			%R13
	inc 	%R15
	xor		%R12,		%R12
	jmp 	_read				# Read file again

_final:
	cmp 	$0,			%R12
	je 		_start_quicksort
	inc 	%rcx
	push	%R12

_start_quicksort:
	mov		$-8,		%R15
	imul	%rcx,		%R15	# TODO change %r14 and %r15 to fit a varying number of list elements
	mov		$-8, 		%r14				# initial value of minimum should be -8 (%rbp - 8 is the first index of the list since %rbp points to the old %rsp)
	#mov		%R12, 		%r15				# initial value of max.
	#sub %r10, %r15				# %rsp = %rbp - k. because of the subtraction sign we use sub to get the value of max. this should work as max = %rbp + (-k)
	movq 	(%rbp, %r14),%mm1

	mov %r15, %r11				# initialize the counter. this should be equal to max - min. this is counted upwards from a negative value to zero
	sub %r14, %r11

	movq $-8, %r13
	movq %R15, %r12

	#call partition
	call quicksort

	jmp _write



# %r15 Used for finding max index in the list. We increment this by 8 every time we count a number. Initial value is -8. This way we get a 0-indexed list
# %r14 Holds min. This is also the index of the element we choose as >>>PIVOT<<<. In the first iteration our min should be index 0
# %r13 tells us where the border between numbers less than or equal to pivot and numbers greater than. Initial value of mid in each iteration should be equal to min.
# %r12 holds the index i of a number we want to compare to. We want to compare the pivot to all elements between A[pivot+1]...A[max]. We jump 8 bytes each time, thus i=min+8 for each partition
# %r11 counts how many elements partition should iterate over. supposed to run as long as 0 < (%r11)=(%r15)-(%r14). note that this results in %r11 needing to be counted as 0 -> 8 -> 16 -> 24...
# %mm1 holds the pivot

.type quicksort, @function
quicksort:

	cmp %r14, %r15
	je return 					# if min is greater than or equal to max
	jg return

	movq (%rbp, %r14), %rcx		# the pivot is the first element in the list and is kept in an mmx register
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

	mov %r15, %r11				# initialize the counter. this should be equal to max - min. this is counted upwards from a negative value to zero
	sub %r14, %r11

	call quicksort

	pop %r14				# min = i-8
	pop %r15				# max = old max from the stack

	mov %r15, %r11				# initialize the counter. this should be equal to max - min. this is counted upwards from a negative value to zero
	sub %r14, %r11

	call quicksort

	return:
	ret

.type partition, @function

partition:
	compare_loop:
	test %r11, %r11				# when %r15 = we have compared all objects
	jz done


	movq 	(%rbp, %r12),	%rdx
	cmp		%rcx,			%rdx
	jbe		less_or_equal
	# subq %rcx, %rdx
	# movq %rdx, %rax
	# test %rax, %rax				# sets sf==1 if (%mm0)<(%mm1) and zf==1 if (%mm0)==(%mm1)
	# js less_or_equal			# if (%mm0)<(%mm1) or
	# jz less_or_equal			# if (%mm0)==(%mm1)

						# else (%mm0)>(%mm1)
	greater:
	subq $8, %r13
	addq $8, %r11
	movq (%rbp, %r12), %rsi
	movq (%rbp, %r13), %rdi
	movq %rdi, (%rbp, %r12)
	movq %rsi, (%rbp, %r13)
	jmp compare_loop

	less_or_equal:
	addq $8, %r12
	addq $8, %r11
	jmp compare_loop

	done:
	movq (%rbp, %r14), %rsi
	movq (%rbp, %r12), %rdi
	movq %rdi, (%rbp, %r14)
	movq %rsi, (%rbp, %r12)

	ret

	_write:
	    xor     %R12,       %R12    # Clear R12, which should hold an integer to be written
	    xor     %R15,       %R15    # Clear R15, for counting length of integer
	    mov     $10,        %R13    # DO NOT TOUCH! - Division by 10.

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
	    jmp _getnum                 # Get new number

	_exit:
	    mov $SYS_EXIT, 		%RAX	# Terminate program
	    mov $0,				%RDI
	    syscall
