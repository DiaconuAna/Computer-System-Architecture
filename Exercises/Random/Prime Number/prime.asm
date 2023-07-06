bits 32 ; assembling for the 32 bits architecture

; declare the EntryPoint (a label defining the very first instruction of the program)
global start      
; declare external functions needed by our program
extern exit, printf, scanf 
extern PrimeCheck 
extern Divisors             ; tell nasm that exit exists even if we won't be defining it
import exit msvcrt.dll    ; exit is a function that ends the calling process. It is defined in msvcrt.dll
import scanf msvcrt.dll                          ; msvcrt.dll contains exit, printf and all the other important C-runtime specific functions
import printf msvcrt.dll
; our data is declared here (the variables needed by our program)
segment data use32 class=data
    print_format db "Input your number: ",0
    read_format db "%d",0
    print_prime db "%d is prime",10,0
    print_not_prime db "%d is not  prime",10,0
    number dd 0

; our code starts here
segment code use32 class=code
    start:
        ;read a number from the keyboard and check if it's  prime
        
        push dword print_format
        call [printf]
        add esp, 4
        
        push dword number
        push dword read_format
        call [scanf]
        add esp, 4*2
        
        push dword [number]
        call PrimeCheck
        add esp, 4
        
        cmp eax,1
        je is_prime
        jmp is_not_prime
        
        is_prime:
        push dword [number]
        push dword print_prime
        call [printf]
        add esp, 4*2
        
        
        
        jmp ending
        
        is_not_prime:
        
        push dword [number]
        push dword print_not_prime
        call [printf]
        add esp, 4*2
        
        ;print the divisors
        push dword[number]
        call Divisors
        add esp, 4
        
        ending:
    
        ; exit(0)
        push    dword 0      ; push the parameter for exit onto the stack
        call    [exit]       ; call exit to terminate the program
