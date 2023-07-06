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
    b db 9
    c db 2
    d dd 5
    e dq 10
    aux dq 0

; our code starts here
segment code use32 class=code
    start:
        ; 2/(a+b*c-9) + e-d 
        ; unsigned representation
        
        ;we compute b*c
        mov AL,[b] ; AL=b
        mul byte[c] ; AX=AL*c=b*c
        
        ;we need to convert byte a into a word in order to be able to add it to b*c
        mov BL,[a] ; BL=a
        mov BH,0 ; unsigned conversion from BL to BX
        ;BX=a
        
        add BX,AX; BX=BX+AX= a+b*c
        mov AX,9
        sub BX,AX ; BX=BX-9 = a+b*c-9
        
        ;2/(a+b*c-9)
        
        ;in order to be able to do the division, 2 must be stored in DX:AX so we perform unsigned conversion
        mov AX,2
        mov DX,0
        ;DX:AX=2
        
        div BX; AX = DX:AX/BX = 2/(a+b*c-9), DX = DX:AX%BX =2%(a+b*c-9)
        
        ;in order to be able to add 2/(a+b*c-9) to the quadword e, we must perform unsigned conversion for the word stored in AX
        mov DX,0
        push DX
        push AX
        pop EAX
        mov EDX,0
        ;EDX:EAX = 2/(a+b*c-9)
        
       ; mov EBX,dword[e]
       ; mov ECX,dword[e+4]
        ;ECX:EBX = e
        
        
        add dword[e],eax
        adc dword[e+4],edx
        ;EAX:EDX = 2/(a+b*c-9) + e 
        
       ; mov EBX,EAX
       ; mov ECX,EDX
        ; ECX:EBX = 2/(a+b*c-9)+e
        
      ; mov BX,word[d]
      ; mov CX,word[d+2]
      ; push cx
      ; push bx
      ; pop ebx
      ; mov ecx,0
       
      ; sub eax,ebx
      ; sbb edx,ecx
        
        ;in order to be able to subtract d from the doubleword stored in ECX:EBX we must convert d into a quadword
       mov AX,word[d]
       mov DX,word[d+2]
       push DX
       push AX
       pop EAX
       ; EAX = d as a doubleword
       mov EDX,0 ;unsigned conversion from EAX to EDX:EAX
        ;EDX:EAX = d
       
       sub dword[e],eax
       sbb dword[e+4],edx
       
       mov eax,dword[e]
       mov edx,dword[e+4]
       
        
        ;ECX:EBX = 2/(a+b*c-9) + e - d
    
        ; exit(0)
        push    dword 0      ; push the parameter for exit onto the stack
        call    [exit]       ; call exit to terminate the program
