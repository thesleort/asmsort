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



.section .text
.globl _start
_start:
	mov 16(%RSP), 		%R8			# File to open

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


_write:								# TODO Put on stack/list instead of printing it.
	mov %RAX, 			%RDX		# Print whatever is in RAX
	mov $SYS_WRITE,		%RAX		# Write
	mov $STDOUT, 		%RDI		# Standard output
	mov $file_buffer, 	%RSI
	syscall							
	jmp _read						# Read file again

_exit:
	mov $SYS_EXIT, 		%RAX		# Terminate program
	mov $0, 			%RDI
	syscall
