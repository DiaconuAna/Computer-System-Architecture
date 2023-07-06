;Given the words A and B, compute the doubleword C as follows:
;the bits 0-3 of C are the same as the bits 5-8 of B
;the bits 4-8 of C are the same as the bits 0-4 of A
;the bits 9-15 of C are the same as the bits 6-12 of A
;the bits 16-31 of C are the same as the bits of B

bits 32 ; assembling for the 32 bits architecture

; declare the EntryPoint (a label defining the very first instruction of the program)
global start        

; declare external functions needed by our program
extern exit               ; tell nasm that exit exists even if we won't be defining it
import exit msvcrt.dll    ; exit is a function that ends the calling process. It is defined in msvcrt.dll
                          ; msvcrt.dll contains exit, printf and all the other important C-runtime specific functions

; our data is declared here (the variables needed by our program)
segment data use32 class=data
     a dw 0011010100011010b
     b dw 1011100010100110b
     c dd 0

; our code starts here
segment code use32 class=code
    start:
        ; c is expected to be 10111000101001101010100110100101b
        ; c = B8A6A9A5h
        
        mov EBX,0 ;we compute the result in ebx
     
    ;part 1: the bits 0-3 of C are the same as the bits 5-8 of B 
        mov AX,[b] 
        ;isolate bits 5-8 of B
        and AX,0000000111100000b
        mov CL,5
        ror AX,CL ;we rotate 5 positions to the right
        mov DX,0
        push DX
        push AX
        pop EAX
        or EBX,EAX ;we put the bits in the result
        
    ;part 2: the bits 4-8 of C are the same as the bits 0-4 of A 
        mov AX,[a]
        ;isolate bits 0-4 of A
        and AX, 0000000000011111b
        mov CL,4
        rol AX,CL ;we rotate 4 positions to the left
        mov DX,0
        push DX
        push AX
        pop EAX ;turned our final number into a doubleword
        or EBX,EAX
        
    ;part 3: the bits 9-15 of C are the same as the bits 6-12 of A
        mov AX,[a]
        ;isolate bits 6-12 of A
        and AX,0001111111000000b
        mov CL,3
        rol AX,CL ;we rotate 3 positions to the left
        mov DX,0
        push DX
        push AX
        pop EAX ;turned our final number intoa doubleword
        or EBX,EAX
        
    ;part 4: the bits 16-31 of C are the same as the bits of B
        mov DX,0
        mov AX,[b]
        push AX
        push DX
        pop EAX  ;turned b into a doubleword
        or EBX,EAX
        
        mov [c], ebx
    
        ; exit(0)
        push    dword 0      ; push the parameter for exit onto the stack
        call    [exit]       ; call exit to terminate the program
