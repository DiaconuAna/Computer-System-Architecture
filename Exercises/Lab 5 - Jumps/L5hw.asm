;2.Given a character string S, obtain the string D containing all special characters (!@#$%^&*) of the string S

bits 32 ; assembling for the 32 bits architecture

; declare the EntryPoint (a label defining the very first instruction of the program)
global start        

; declare external functions needed by our program
extern exit               ; tell nasm that exit exists even if we won't be defining it
import exit msvcrt.dll    ; exit is a function that ends the calling process. It is defined in msvcrt.dll
                          ; msvcrt.dll contains exit, printf and all the other important C-runtime specific functions

; our data is declared here (the variables needed by our program)
segment data use32 class=data
    s db  '%', '^', '2', 'a', '@', '3', '$', '*'
    l1 equ $-s
    d times l1 db 0 
    special db '!','@','#','$','%','^','&','*'
    l2 equ $-special
    aux dd 0 
    index db 0

; our code starts here
segment code use32 class=code
    start:
        mov ecx,l1
        mov esi,0 ;index register for s 
        mov edx,0 ;index register for d
        jecxz end1; if s has no element there is no need for a loop
        
       do:
           mov al,[s+esi]
           mov [aux],ecx ;we store ecx in aux for further reference
           mov edi,0 ;index for special character string
           mov ecx,l2 ;ecx takes the length of special string as we enter another loop of special's elements
            
              check:
                 mov bl,[special+edi]
                 cmp al,bl ;if the current element from s is a special character
                 je ending ;get out of the loop
                 inc edi ;else increase the index and keep looking
              loop check
           
           cmp ecx,0 
           je next ;if ecx is 0 means that the current element from s is not a special character
           
           ending:
              mov bl,1 ;if the current element from s is a special character we signal it by putting 1 in the BL register
           
           next:
            mov ecx,[aux] ;our previous ecx value is restored
            cmp bl,1
            jne again ;if BL!=1 => current element from s is not a special character so we move on to the next element in s
            je add_to_d ;if BL == 1 => current element from s is a special character so we add it to d (edx is the index of the string d)
             
             add_to_d:
                mov [d+edx],al
                inc edx
            
            again:
                inc esi
      
       loop do
         
         end1:
         
                                    
        
    
        ; exit(0)
        push    dword 0      ; push the parameter for exit onto the stack
        call    [exit]       ; call exit to terminate the program
