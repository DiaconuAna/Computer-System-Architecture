bits 32 ; assembling for the 32 bits architecture

; declare the EntryPoint (a label defining the very first instruction of the program)
global start        

; declare external functions needed by our program
extern exit, printf, scanf               ; tell nasm that exit exists even if we won't be defining it
import exit msvcrt.dll
import printf msvcrt.dll
import scanf msvcrt.dll    
; msvcrt.dll contains exit, printf and all the other important C-runtime specific functions
; our data is declared here (the variables needed by our program)
segment data use32 class=data
    a dd 0
    b dd 0
    format db "%d", 0
    msg_a db "a= ", 0
    msg_b db "b= ", 0
    msg_result db "%d/%d = %d ",0
    result dd -1

; our code starts here
segment code use32 class=code
;Read two numbers a and b (in base 10) from the keyboard and calculate a/b. This value will be stored in a variable called "result" (defined in the ;data segment). The values are considered in signed representation.
    start:
        ;printf("a= ")
        push dword msg_a
        call [printf]
        add esp, 4
        
        ;scanf("%d",&a)
        push dword a
        push format
        call [scanf]
        add esp, 4*2
        
        ;printf("b= ")
        push dword msg_b
        call [printf]
        add esp, 4
        
        ;scanf("%d",&b)
        push dword b
        push format
        call [scanf]
        add esp, 4*2
        
        mov eax,[a]
        cdq ;signed conversion eax -> edx:eax
        idiv dword[b] ;signed division, eax = a/b 
        mov dword[result],eax ;result = a/b
        
        ;printf(" %d / %d = %d", a,b,result)
        push dword [result]
        push dword [b]
        push dword [a]
        push dword msg_result
        call [printf]
        add esp, 4*4
        

        
        ; exit(0)
        push    dword 0      ; push the parameter for exit onto the stack
        call    [exit]       ; call exit to terminate the program
