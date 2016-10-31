.section .data
newline: .string "\n"

.section .bss
    .set SYS_WRITE, 1
    .set SYS_EXIT,	60
    .set STDOUT, 	1
    .lcomm int_buffer, 8

.section .text
.globl _start

_start:
    xor     %R12,       %R12    # Clear R12, which should hold an integer to be written
    xor     %R15,       %R15    # Clear R15, for counting length of integer
    mov     $10,        %R13    # DO NOT TOUCH! - Division by 10.

    push    $1234
    push    $4325
    push    $1337

_getnum:
    xor     %R12,       %R12
    pop     %R12
    cmp     $0,         %R12
    je      _exit

_convert:
    inc     %R15                # Increase digit counter.
    mov     %R12,       %RAX    # Move integer for div instruction.
    xor     %RDX,       %RDX    # Set RDX to 0 for division.
    div     %R13                # Execute the division.
    add     $48,        %RDX    # RDX holds the remainder from division, and we add 48 to convert to ascii.
    push    %RDX                # We push RDX to the stack so we can get digits out in correct order.
    mov     %RAX,       %R12    # RAX holds the number after division has been executed, and we move it back into R12
    cmp     $0,         %R12    # if R12 is 0, we are done with this number and we can start printing it
    je      _print              # Print the number
    jmp     _convert            # Otherwise, keep converting the number to digits.

_print:
    pop     %R14
    mov     $int_buffer,%R12
    mov     %R14,       (%R12)
    mov     $SYS_WRITE, %RAX
    mov     $STDOUT,    %RDI
    mov     %R12,       %RSI
    mov     $1,         %RDX
    syscall

    dec     %R15
    cmp     $0,         %R15
    je      _newline             # End of integer
    jmp     _print

_newline:
    mov $SYS_WRITE,		%RAX
    mov $STDOUT,		%RDI
    mov $newline,		%RSI
    mov $1,				%RDX
    syscall
    jmp _getnum                 # Get new number

_exit:
    mov $SYS_EXIT, 		%RAX	# Terminate program
    mov $0,				%RDI
    syscall
