bits 32 ; assembling for the 32 bits architecture

; declare the EntryPoint (a label defining the very first instruction of the program)
global start        

; declare external functions needed by our program
extern exit               ; tell nasm that exit exists even if we won't be defining it
import exit msvcrt.dll    ; exit is a function that ends the calling process. It is defined in msvcrt.dll
                          ; msvcrt.dll contains exit, printf and all the other important C-runtime specific functions

; our data is declared here (the variables needed by our program)
segment data use32 class=data
    
    a db 3
    b dw 10
    c dd 7
    d dq 9

; our code starts here
segment code use32 class=code
    start:
    
    ; (b+b) + (c-a) + d
        
        
        ;we first compute c-a
       
       
       mov BL,[a] ;BL = a
       ; we need to convert the byte a to a doubleword in order to be able to subtract it from c
       mov BH,0; unsigned conversion from BL to BX
       mov CX,0;unsigned conversion from BX to CX:BX
       ;cx:bx=a
       
       mov AX,word[c]
       mov DX,word[c+2]
       ;dx:ax=c
       
       sub ax,bx
       sbb dx,cx
       ;dx:ax = c-a
        
        ; we compute b+b
        
       mov BX,[b] ; BX = b
       add BX,[b] ; BX = BX + b = b + b
       ;we need to convert the word b to a doubleword in order to be able to add it to (c-a)   
       mov CX,0   ; unsigned conversion from BX to CX:BX
       ; cx:bx = b+b
        
    
        ; we compute (b+b) + (c-a)
        add AX,BX
        adc DX,CX
        ;DX:AX= (b+b) + (c-a)
        
        push DX
        push AX
        pop EAX 
        ; EAX = DX:AX = (b+b) + (c-a)
        
        ;(b+b) + (c-a) + d
        
        ;we need to convert the EAX doubleword to a quadword in order to be able to add it to d
        mov EDX,0; conversion from EAX to EDX:EAX
        ;edx:eax = (b+b) + (c-a)
        add EAX, dword[d]
        adc EDX, dword[d+4]
        ;edx:eax = (b+b) + (c-a) + d
    
        ; exit(0)
        push    dword 0      ; push the parameter for exit onto the stack
        call    [exit]       ; call exit to terminate the program
