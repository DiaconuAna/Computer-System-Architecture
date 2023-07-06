bits 32 ; assembling for the 32 bits architecture

; declare the EntryPoint (a label defining the very first instruction of the program)
global start        

; declare external functions needed by our program
extern exit, fread, fopen, fclose, printf 
extern number_of_apparitions_in_file
;extern in_array              ; tell nasm that exit exists even if we won't be defining it
import exit msvcrt.dll    ; exit is a function that ends the calling process. It is defined in msvcrt.dll
import fread msvcrt.dll                          ; msvcrt.dll contains exit, printf and all the other important C-runtime specific functions
import fopen msvcrt.dll
import fclose msvcrt.dll
import printf msvcrt.dll

; our data is declared here (the variables needed by our program)
segment data use32 class=data
    file_name db "file_2.txt",0
    file_descriptor dd 0
    read_mode db "r",0
    read_char db 0
    character_array resb 100
    times_in_array resb 100
    array_length dd 0
    aux dd 0
    print_char_format db "%c :",0
    decimal_format db " %d ",10, 0
    dec_format2 db "%d. ",0
    savedECX dd 0
    ok db 0
    current_index  dd 0
    

; our code starts here
segment code use32 class=code
    start:
        ;02.	Se citeste un text din fisier si un character de la tastatura.
        ; b)	Afisati top 5 caractere ca frecventa in textul dat, afisand (nrcrt character frecventa).
        
        ;first we open the file
        ;fopen(file_name, access_mode)
        push dword read_mode
        push dword file_name
        call [fopen]
        add esp, 4*2
        
        
        
        
        
        cmp eax,0
        je ending
        
        mov [file_descriptor], eax
        
        ;we read a character from the file at a time and if it hasn't been added
        ;to character_array before, we add it
        
        cld
        mov edi, character_array
        
        read_chars:
        ;fread(read_char,1,1,file_descriptor)
        push dword[file_descriptor]
        push dword 1
        push dword 1
        push dword read_char
        call [fread]
        add esp, 4*4
        
        cmp eax,0
        je compute_frequency
        
        ;check if the character is in the array
         mov esi, character_array
         mov ecx, [array_length]
         cmp ecx, 0
         je add_char
        characters:
        lodsb
        cmp al,[read_char]
        je equal
        loop characters
        jmp add_char

        equal:
        mov eax,0
        jmp read_chars
        
        add_char:
        mov al, [read_char]
        stosb
        inc dword[array_length]
        jmp read_chars
        
        
     
      compute_frequency:
      
      ;we first close the file
      
      push dword[file_descriptor]
      call [fclose]
      add esp, 4
      
      ;for each character in character_array we see how many times it appears in the file and store the said number in times_in_array
    
      mov esi, character_array
      mov ecx, [array_length]
      mov edi, times_in_array
      
     frequency:
     mov [savedECX], ecx
     lodsb
     
     push eax
     push dword file_name
     call number_of_apparitions_in_file
     add  esp, 4*2
     
     stosb ;storing the frequency in the other array
     mov ecx, [savedECX]
     loop frequency
      
      ;  print_chars:
       ; mov esi, times_in_array
       ; mov ecx, [array_length]
        
       ; print_loop:
       ; mov [savedECX], ecx
        
      ;  lodsb
      ;  mov dword[read_char],0
      ;  mov [read_char],al
      ;  push dword[read_char]
      ;  push dword decimal_format
      ;  call [printf]
      ;  add esp, 4*2
        
      ;  mov ecx,  [savedECX]
      ;  loop print_loop
      
      
      ;now we sort the times_in_array in descending order,  along with character_array
      
      mov esi, times_in_array
      mov edi, character_array
      
      bubble_sort: ;decreasing order for bytes
      
      mov byte[ok], 1
      
      mov esi, times_in_array
      mov edi, character_array
      
      mov dword[current_index], 0
      
      compare:
        
        mov cl, byte[esi]
        mov ch, byte[esi+1]
        cmp cl,ch ;if v[i] < v[i+1]
        
        jae again
        ;else interchange 
        mov byte[esi],ch
        mov byte[esi+1],cl
        
        mov cl, byte[edi]
        mov ch, byte[edi+1]
        
        mov byte[edi],ch
        mov byte[edi+1],cl
        
        mov byte[ok], 0
        
        again:
        add esi,1
        add edi, 1
        add dword[current_index], 1
        mov ecx, dword[array_length]
        sub ecx,1
        
        cmp dword[current_index], ecx
        jb compare
        
        cmp byte[ok], 0
        
        je bubble_sort
      
      
     ;now we display the top 5
     mov ecx, 5
     
      
      mov edi, times_in_array
      mov esi, character_array
      
      display_top_5:
      mov [savedECX], ecx
      
      mov ebx,6
      sub ebx,ecx
      
      push ebx
      push dword  dec_format2
      call [printf]
      add esp, 4*2
  
      
      mov eax,0
      mov al,byte[esi]
      push eax 
      push dword print_char_format
      call [printf]
      add esp, 4*2
      
      mov al,byte[edi]
      push eax 
      push dword decimal_format
      call [printf]
      add esp, 4*2
      
      inc edi
      inc esi
      
      mov ecx,[savedECX]
      loop display_top_5
      
      
      
     
        
        ending:
        ; exit(0)
        push    dword 0      ; push the parameter for exit onto the stack
        call    [exit]       ; call exit to terminate the program
 