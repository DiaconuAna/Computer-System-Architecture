bits 32 ; assembling for the 32 bits architecture

; declare the EntryPoint (a label defining the very first instruction of the program)
global start        

; declare external functions needed by our program
extern exit               ; tell nasm that exit exists even if we won't be defining it
import exit msvcrt.dll    ; exit is a function that ends the calling process. It is defined in msvcrt.dll
                          ; msvcrt.dll contains exit, printf and all the other important C-runtime specific functions

; our data is declared here (the variables needed by our program)
segment data use32 class=data
    s db 2,1,5,3,2,8,9
    l equ $-s
    d1 times l db -1
    d2 times l db -1
; our code starts here
segment code use32 class=code
    start:
        mov ecx,l
        mov esi,0
        mov edx,0
        mov edi,0
        
        jecxz sfarsit
        
        repeta:
        mov al,[s+esi]
        mov ah,0
        mov bl,2
        div bl
        cmp al,1
        je impar
        jmp par
        
        impar:
        mov al,[s+esi]
        mov [d2+edi],al
        inc edi
        jmp again
        
        par:
        mov al,[s+esi]
        mov [d1+edx],al
        inc edx
        
        
        again:
        inc esi
        loop repeta
        
        sfarsit:
    
        ; exit(0)
        push    dword 0      ; push the parameter for exit onto the stack
        call    [exit]       ; call exit to terminate the program
