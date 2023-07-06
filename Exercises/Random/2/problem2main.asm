bits 32 ; assembling for the 32 bits architecture

; declare the EntryPoint (a label defining the very first instruction of the program)
global start        

; declare external functions needed by our program
extern exit, printf, scanf, fopen, fclose, fread, fprintf 
extern is_letter 
extern caesar_cipher            ; tell nasm that exit exists even if we won't be defining it
import exit msvcrt.dll    ; exit is a function that ends the calling process. It is defined in msvcrt.dll
import printf msvcrt.dll                         ; msvcrt.dll contains exit, printf and all the other important C-runtime specific functions
import scanf msvcrt.dll
import fopen msvcrt.dll
import fclose msvcrt.dll
import fread msvcrt.dll
import fprintf msvcrt.dll


; our data is declared here (the variables needed by our program)
segment data use32 class=data
    ;a)
    input_file_name db "input.txt",0
    output_file_name db "output.txt",0
    input_file_descriptor dd 0
    output_file_descriptor dd 0
    file_length dd 0
    read_char db 0
    read_char_format db "%c",0
    read_mode db "r",0
    write_mode db "w",0
    file_char db 0
    frequency_of_char dd 0
    frequency_format db "The character %c appears in the text for %d times",10,0
    length_format db "The length of the file is %d",10,0
    prev_char db 0
    number_of_words dd  0
    words_format db "The text has %d words",10,0
    
    ;c)
    code_file_name db "cipher.txt",0
    code_file_descriptor dd 0
    

; our code starts here
segment code use32 class=code
    start:
        ;  read character from keyboard
        ; scanf("%c", read_char)
        push dword read_char
        push dword read_char_format
        call [scanf]
        add esp, 4*2
        
        ;fopen(file_name, access_mode)
        push dword read_mode
        push dword input_file_name
        call [fopen]
        add esp, 4*2
        
        cmp eax, 0
        je over
        
        mov [input_file_descriptor], eax
        
        ;fopen(file_name, access_mode)
        push dword write_mode
        push dword output_file_name
        call [fopen]
        add esp, 4*2
        
        cmp eax, 0
        je over
        
        mov [output_file_descriptor], eax
        
        
        ;now we read characters from the input file
        read_from_file:
        ;fread(file_char, 1,1, input_file_descriptor)
        push dword [input_file_descriptor]
        push dword 1
        push dword 1
        push dword file_char
        call [fread]
        add esp, 4*4
        
        cmp eax,0
        je next_point
        
        add [file_length], eax
        
        mov eax, dword[read_char]
        cmp al, [file_char]
        je write_x
        jne write_char
        
        write_x:
        ;fprintf(output_file_descriptor, "%c", 'X')
        ;ascii code of 'X' is 58h
        push dword 58h
        push dword read_char_format
        push dword [output_file_descriptor]
        call [fprintf]
        add esp, 4*3
        
        inc dword[frequency_of_char]
        
        jmp read_from_file
        write_char:
        ;fprintf(output_file_descriptor, "%c", file_char)
        push dword [file_char]
        push dword read_char_format
        push dword [output_file_descriptor]
        call [fprintf]
        add esp, 4*3
        
        jmp read_from_file
        
     
    
    next_point:
    
     ;close the file
      ;fclose(input_file_descriptor)
      push dword[input_file_descriptor]
      call [fclose]
      add esp, 4
      
      push dword[output_file_descriptor]
      call [fclose]
      add  esp, 4
      
    ;print the frequency of the read_char
    ;printf(format, frequency_of_char, read_char)
    push dword[frequency_of_char]
    push dword [read_char]
    push dword frequency_format
    call [printf]
    add esp, 4*2
    
    ;printf the length of the file- point d)
    push dword [file_length]
    push dword length_format
    call [printf]
    add esp, 4*2
    
    ;we reread the file  to count the words
        push dword read_mode
        push dword input_file_name
        call [fopen]
        add esp, 4*2
        
    ;read 1 character at a time. A word is marked when the 
    ;previous character is a letter and the current one is not
     read_words:
        ;fread(file_char, 1,1, input_file_descriptor)
        push dword [input_file_descriptor]
        push dword 1
        push dword 1
        push dword file_char
        call [fread]
        add esp, 4*4
        
        cmp eax,0
        je over 
        
        push dword[file_char]
        call is_letter
        add esp, 4
        
        cmp eax,0 ;if eax is 0 it means the current character is not a letter so we check if  a word has just ended(the prev char is a letter)
        je check_for_word
        jne again
        
        check_for_word:
        push dword[prev_char]
        call is_letter
        add esp, 4
        
        cmp eax,1
        je  count_word
        jne again
        
        count_word:
        add dword[number_of_words], 1
             
        again:
        mov al,[file_char]
        mov [prev_char], al
        jmp read_words
    
    over:
    ; we close the file 
      push dword[input_file_descriptor]
      call [fclose]
      add esp, 4
    ;we print the number of words from the file
       
       push dword[number_of_words]
       push dword words_format
       call [printf]
       add esp, 4*2
   
   ;c)	Codificati textul folosind corespondenta ABCDâŚ WXYZ -> CDEFâŚ  YZAB si afisati condificarea intr-un nou fisier.
   ;we reopen the initial file
   push dword read_mode
   push dword input_file_name
   call [fopen]
   add esp, 4*2
   
   cmp eax,0
   je goodbye
   
   mov [input_file_descriptor], eax
   
   ;and the file in which we write the encoded text
   push dword write_mode
   push dword code_file_name
   call [fopen]
   add esp, 4*2
   
   cmp eax,0
   je goodbye
   
   mov [code_file_descriptor], eax
   
   ;we read a character from the file and if it's a letter, we encode it
   code_read:
   ;fread(file_char,1,1,input_file_descriptor)
   push dword [input_file_descriptor]
   push dword 1
   push dword 1
   push dword read_char
   call [fread]
   add esp, 4*4
   
   cmp eax,0
   je goodbye
   
   mov eax,dword[read_char]
   
   ;we check if the current character is a letter
   push eax
   call is_letter
   add esp, 4
   
   cmp eax,1
   je caesar_encode
   jne write_to_file ;if it's not a letter, we don t need to encode it so we just write it into the file
   
   
   caesar_encode:
   push dword[read_char]
   call caesar_cipher
   add esp, 4
   ;the encoded letter is stored in al
   mov [read_char], al
   
   write_to_file:
   push dword [read_char]
   push dword read_char_format
   push dword[code_file_descriptor]
   call [fprintf]
   add esp, 4*3
   
   jmp code_read 
   
   
   goodbye:

    
        ; exit(0)
        push    dword 0      ; push the parameter for exit onto the stack
        call    [exit]       ; call exit to terminate the program
