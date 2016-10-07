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
    cmp $48, %rbx         # If the character is anything less than ascii number 48, then we have reached the end.
  jl convertdone
    mov $10, %rcx
    mul %rcx              # mult multiplies %rax with the given operand and saves the result in %rdx:%rax.
                          # I multiply by 10 to shift the number one placement to the right to add the newest integer.
    sub $48, %rbx         # In ascii, numbers start at 0 = 48, 1 = 49, 2 = 50 and so on. So I subtract 48 to get the digit.
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
