bits 32
global Divisors
extern fprintf, printf, fopen, fclose
import fprintf msvcrt.dll
import printf msvcrt.dll
import fopen msvcrt.dll
import fclose msvcrt.dll

segment data use 32
  number dd 0
  divisor_format db "%d ",0

segment code use 32
Divisors:
    mov edx, [esp+4]
    mov [number], edx
 
    mov ebx, 2
    
    divisors_loop:
    mov eax,[ number]
    mov edx,0
    div ebx
    cmp edx,0
    je show_divisor
    jmp next
    
    show_divisor:
    push dword eax
    push dword divisor_format
    call [printf]
    add esp, 4*2
    
    next:
    add ebx, 1
    cmp ebx, [number]
    jb divisors_loop
    
    ret
    
    
   
