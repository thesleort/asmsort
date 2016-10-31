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
    mov     $10,        %R13    # DO NOT TOUCH!
    push    $1234
    push    $4325
    push    $1337

_getnum:
    xor     %R12,       %R12
    pop     %R12
    cmp     $0,         %R12
    je      _exit

_convert:
    inc     %R15
    mov     %R12,       %RAX
    mov     $0,         %RDX
    div     %R13
    add     $48,        %RDX
    push    %RDX
    mov     %RAX,       %R12
    cmp     $0,         %R12
    je      _print              # Print the number
    jmp     _convert

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
