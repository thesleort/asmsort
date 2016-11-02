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
	mov 48(%RBX),		%RDX	# Position of size in the struct

	mov $SYS_READ,		%RAX	# Read file
	mov %R9,			%RDI	# File descriptor from before
	mov $file_buffer,	%RSI	#
	syscall
	mov $file_buffer,	%R15


_read:

	xor %RDX,			%RDX
	movb (%R15),		%dl		# dl is in RDX

	cmp $0,				%dl		# Ensure haven't read EOF
	je _exit					# Stop reading file


	cmp $0xA,			%dl
	je _write
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

_write:	# TODO Put on stack/list instead of printing it.

	push %R12

	mov $1,				%R13
	inc %R15
	jmp _read					# Read file again


_exit:
	mov $SYS_EXIT, 		%RAX	# Terminate program
	mov $0,				%RDI
	syscall
