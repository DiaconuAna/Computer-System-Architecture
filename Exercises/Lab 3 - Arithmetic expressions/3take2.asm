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
    d dd 2
    e dq 6

; our code starts here
segment code use32 class=code
    start:
    ;2/(a+b*c-9)+e-d; a,b,c-byte; d-doubleword; e-qword
    
       mov AL,[b] ; al=b
       mul byte[c] ; ax = b*c
       mov bx,ax ; bx = ax = b*c
       
       mov al,[a] ; al=a
       mov ah,0 ; unsigned conversion from al to ax
       add ax,bx ; ax = ax + bx = a + b*c
       sub ax,9 ; ax = a+ b*c - 9
       mov bx,ax ; bx = a+b*c-9
       
       mov ax,2 ; ax = 2
       mov dx,0 ; unsigned conversion from ax to dx:ax
       div bx ; ax = 2/(a+b*c-9)
       mov dx,0 ; unsigned conversion from ax to dx:ax
      
       push dx
       push ax
       pop eax   ; eax = 2/(a+b*c-9)
       mov edx,0 ;unsigned conversion from eax to edx:eax (double to quad)
       
       ; 2/(a+b*c-9)+e
       add dword[e],eax
       adc dword[e+4],edx
       
       mov bx,word[d] 
       mov cx,word[d+2]
       push cx
       push bx
       pop ebx  ; ebx = d
    
       ;mov ebx,d 
       mov ecx,0  ; unsigned conversion from ebx to ecx:ebx
     
        
      ; 2/(a+b*c-9)+e-d
      
        sub dword[e],ebx  
        sbb dword[e+4],ecx  ; 
      


      ;to check if the result is right(in ollydbg)
       mov eax,dword[e]
       mov edx,dword[e+4]
       
       
      
    
        ; exit(0)
        push    dword 0      ; push the parameter for exit onto the stack
        call    [exit]       ; call exit to terminate the program
