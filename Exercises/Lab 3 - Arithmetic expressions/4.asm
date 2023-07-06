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
    b db 5
    c db 7
    d dd 9
    e dq 6

; our code starts here
segment code use32 class=code
    start:
    ; 2/(a+b*c-9)+e-d
       mov AL,[b] ;AL = b
       imul byte[c] ; AL = Al * c = b * c
       mov bx,ax ; BX = b * c
       
       mov al,[a] ; AL = a
       cbw ; signed conversion AL -> AX
       add ax,bx ; AX = AX + BX = a + b*c
       sub ax,9 ; AX = AX - 9 = a + b*c - 9
       mov bx,ax ; BX = a + b*c - 9
       
       mov ax,2 ; AX = 2
       cwd ;signed conversion AX->DX:AX
       ;mov dx,0 ; DX = 0
       idiv bx  ; AX = DX:AX / BX ; AX = 2/(a+b*c-9)
       cwde  ; AX -> EAX
       cdq ; EAX -> EDX:EAX
       ; EDX:EAX = 2/(a + b*c - 9) -converted it into a quad so we could add it to e
       
       mov EBX,EAX 
       mov ECX,EDX
      ; ECX:EBX = 2/(a+b*c-9)
  
       add dword[e],ebx
       adc dword[e+4],ecx
       
         ; 2/(a+b*c-9)+ e 
  
     
       mov ax,word[d]
       mov dx,word[d+2]
       push dx
       push ax
       pop eax
       ;eax = d 
       cdq ;converted d from a doubleword to a quad so we can substract it from the rest of the expression
       
        
      ; 2/(a+b*c-9)+e-d
      
        sub dword[e],eax
        sbb dword[e+4],edx
       
       mov EAX,dword[e]
       mov EDX,dword[e+4]
       
      
    
        ; exit(0)
        push    dword 0      ; push the parameter for exit onto the stack
        call    [exit]       ; call exit to terminate the program
