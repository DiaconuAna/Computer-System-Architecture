bits 32
global PrimeCheck
extern fprintf, printf, fopen, fclose
import fprintf msvcrt.dll
import printf msvcrt.dll
import fopen msvcrt.dll
import fclose msvcrt.dll

segment data use 32
  number dd 0
  print_format db "hey",0

segment code use 32

PrimeCheck:
    ;number is stored in [esp+4]
    mov edx, [esp+4]
    mov dword[number], edx
    cmp edx, 2
    jb not_prime
    je prime
       
    
    mov ebx,2
    mov eax, edx
    mov edx,0
    div ebx
    cmp edx,0
    je not_prime
    
    mov edx, [number]
    mov ebx,3
    
    cmp ebx, [number]
    jb prime_loop
    jmp prime ;in this case, the number is 3
    prime_loop:
    mov eax,dword [number]
    mov edx,0
    div ebx
    cmp edx, 0
    je not_prime
    
    add ebx, 2
    
    cmp  ebx, [number]
    jb prime_loop
    
    jmp prime 
    
    
    not_prime:
    mov eax, 0
    ret
    
    
    prime:
    mov eax,1
    ret