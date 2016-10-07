.section .data
buffer: .space 64

newline: .string "\n"

.section .text
.globl _start
_start:
	mov 16(%rsp), %r8	#File to open

	mov $2, %rax	#Open file
	mov %r8, %rdi
	mov $0, %rsi
	mov $2, %rdx
	syscall
	
	mov %rax, %r9		

	mov $0, %rax	#Read file
	mov %r9, %rdi
	mov $buffer, %rsi
	mov $11, %rdx
	syscall
	
	mov $1, %rax	#Write to command line
	mov $1, %rdi
	mov $buffer, %rsi
	mov $11, %rdx
	syscall
	
	
	mov $1, %rax	#Write a new line
	mov $1, %rdi
	mov $newline, %rsi
	mov $2, %rdx
	syscall

	mov $60, %rax
	mov $0, %rdi
	syscall
