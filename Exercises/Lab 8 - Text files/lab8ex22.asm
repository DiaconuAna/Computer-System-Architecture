bits 32 ; assembling for the 32 bits architecture

; declare the EntryPoint (a label defining the very first instruction of the program)
global start        

; declare external functions needed by our program
extern exit, printf, fread, fclose, fopen             ; tell nasm that exit exists even if we won't be defining it
import exit msvcrt.dll  
import printf msvcrt.dll
import fread msvcrt.dll
import fclose msvcrt.dll  
import fopen msvcrt.dll

; our data is declared here (the variables needed by our program)
segment data use32 class=data
    file_name db "file1.txt",0
    access_mode db "r",0
    file_descriptor dd -1
    characters_read dd 0
    maxlen equ 100
    string resb maxlen
    consonants db 'b','B','c','C','d','D','f','F','g','G','h','H','j','J','k','K','l','L','m','M','n','N','p','P','q','Q','r','R','s','S','t','T','v','V','w','W','x','X','y','Y','z','Z',0
    consonantslen equ 42
    number_of_consonants dd 0
    consonant_format db "The text contains %d consonants.",0
    consonant db -1
    counter dd 0

; our code starts here
segment code use32 class=code
;A text file is given. Read the content of the file, count the number of consonants and display the result on the screen. The name of text file is ;defined in the data segment.

    start:
         ; eax = fopen("file.txt","r") -opening file.txt in read mode, the file has already been created
         push dword access_mode ;access_mode = 'r'
         push dword file_name 
         call [fopen]
         add esp, 4*2 ;removing params from the stack
         
         ;check if the file has been succesfully opened
          
          cmp eax,0
          je final ;if eax is 0 after opening the file it means an error has occured
          mov [file_descriptor], eax 
          
          ;since our text file may have a large size we read it in a loop 
          read_loop:
           ;eax = fread(string, 1, maxlen, file_descriptor)
           push dword [file_descriptor] ;file identifier
           push dword maxlen ;maximum number of elements to be read from the file
           push dword 1 ;size of one element that will be read from the file- we want to read bytes 
           push dword string ;address of the string where the data read from the file is stored
           call [fread] 
           add esp, 4*4 ;removing parameters from the stack
           
           ;eax contains the number of bytes that have been read from the file
           cmp eax ,0 ;if eax = 0 we have reached eof
           je cleanup ;so we close the file 
           
           mov ecx, eax 
           mov esi, string
            
            consonant_loop:
            ;here we take each letter from the string and check whether it is a consonant or not
            
            lodsb ;the current letter from the string will be stored in AL
            mov edx,0
            mov [counter],ecx  ;we save ecx for further reference
            mov ecx, 42 ;length of array of consonants
            
            ;here we check whether a letter is a consonant by comparing it to every consonant in the alphabet
            ;the search is over either when we find a consonant or we have compared the letter to all consonants
            consonant_check:
            mov bl, [consonants+edx]
            cmp al,bl
            je increase_counter ;if equal, we have found a consonant so we can get out of the search loop 
            inc edx ;else we continue the checking by increasing the consonant array index
            
            loop consonant_check
            jmp again ;if the given letter is not a consonant, we don't increase the counter
            
            increase_counter:
            add dword[number_of_consonants], 1 ;increasing the counter in case the given letter is a consonant
 
            again:
            mov ecx, [counter]
            dec ecx
            
            jnz consonant_loop
           
           jmp read_loop
    
        cleanup:
         ; here we close the file
         ; fclose(file_descriptor)
         push dword [file_descriptor]
         call [fclose]
         add esp, 4
         
        final: 
        ; printf("The text contains %d consonants", number_of_consonants)
        push dword [number_of_consonants]
        push dword consonant_format
        call [printf]
        add esp, 4*2
        
        ; exit(0)
        push    dword 0      ; push the parameter for exit onto the stack
        call    [exit]       ; call exit to terminate the program
