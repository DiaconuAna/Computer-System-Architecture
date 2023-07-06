bits 32 ; assembling for the 32 bits architecture

; declare the EntryPoint (a label defining the very first instruction of the program)
global start        

; declare external functions needed by our program
extern exit               ; tell nasm that exit exists even if we won't be defining it
import exit msvcrt.dll    ; exit is a function that ends the calling process. It is defined in msvcrt.dll
                          ; msvcrt.dll contains exit, printf and all the other important C-runtime specific functions

; our data is declared here (the variables needed by our program)
segment data use32 class=data
    a db 2
    b dw 13
    c dd 9
    d dq 6

; our code starts here
segment code use32 class=code
    start:
        ; (c+b)-a-(d+d)
        
        mov AX,[b] ;AX = b
        cwd ;signed conversion from AX to DX:AX
        
        mov BX,word[c]
        mov CX,word[c+2]
        ;CX:BX = c
        
        add BX,AX
        adc CX,DX
        ; CX:BX = c + b
        
        ;we need to convert byte a to a doubleword in order to be able to add it to b+c
        mov AL,[a] ; AL=a 
        cbw ;signed conversion from AL to AX
        cwd ;signed conversion from AX to DX:AX
        
        sub BX,AX
        sbb CX,DX
        ;CX:BX = (c+b) - a
        
        push CX
        push BX
        pop EAX
        ;EAX = (c+b)-a
        
        mov EBX,dword[d]
        mov ECX,dword[d+4]
        ;ECX:EBX = d
        
        
        add EBX,EBX
        adc ECX,ECX
        ;ECX:EBX = d+d
        
        ;we need to convert the doubleword EAX to a quadword so that we can subtract (d+d) from it
        cdq ;signed conversion from EAX to EDX:EAX
        ;EDX:EAX = (c+b)-a
        sub EAX,EBX
        sbb EDX,ECX
        ;EDX:EAX = (c+b)-a-(d+d)
       
        
        
        
        
        ; exit(0)
        push    dword 0      ; push the parameter for exit onto the stack
        call    [exit]       ; call exit to terminate the program
