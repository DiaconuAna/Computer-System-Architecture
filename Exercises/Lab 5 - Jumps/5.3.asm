bits 32 ; assembling for the 32 bits architecture

; declare the EntryPoint (a label defining the very first instruction of the program)
global start        

; declare external functions needed by our program
extern exit               ; tell nasm that exit exists even if we won't be defining it
import exit msvcrt.dll    ; exit is a function that ends the calling process. It is defined in msvcrt.dll
                          ; msvcrt.dll contains exit, printf and all the other important C-runtime specific functions

; our data is declared here (the variables needed by our program)
segment data use32 class=data
    s db 1,2,3,4
    l1 equ $-s
    s2 db 5,6,7
    l2 equ $-s2
    d times l1+l2 db -1

; our code starts here
segment code use32 class=code
    start:
        mov ecx,l1
        mov esi,s
        mov edi,d
        cld
        jecxz the_end
        
        do:
        movsb
        loop do
        
        the_end:
        mov esi,s2+l2-1
        mov edx,l1
        std
        mov ecx,l2
        jecxz the_other_end
        do1:
        lodsb
        mov [d+edx],al
        inc edx
        loop do1
        
        the_other_end:
    
        ; exit(0)
        push    dword 0      ; push the parameter for exit onto the stack
        call    [exit]       ; call exit to terminate the program
