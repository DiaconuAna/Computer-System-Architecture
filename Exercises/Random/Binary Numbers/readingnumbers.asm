bits 32 ; assembling for the 32 bits architecture

; declare the EntryPoint (a label defining the very first instruction of the program)
global start        

; declare external functions needed by our program
extern exit, printf, fread,fopen, fclose       
extern printBinary   
extern PrimeCheck  
extern Divisors   ; tell nasm that exit exists even if we won't be defining it
import exit msvcrt.dll    ; exit is a function that ends the calling process. It is defined in msvcrt.dll
import printf msvcrt.dll
import fread msvcrt.dll
import fopen msvcrt.dll
import fclose msvcrt.dll                 ; msvcrt.dll contains exit, printf and all the other important C-runtime specific functions

; our data is declared here (the variables needed by our program)
segment data use32 class=data
    file_format db "number_file.txt",0
    digit dd 0
    number_array resd 100
    array_length dd 0
    neg_flag db 0
    aux db 0
    file_descriptor dd 0
    access_mode db "r",0
    number dd 0
    print_format db "%d ",0
    savedECX dd 0
    
    ;point a)
    sum dd 0
    product dd 1
    max dd 0
    sum_format db "Sum is %d",10,0
    product_format db "Product is %d",10,0
    max_format db "Maximum is %d",10,0
    positions_format db "Maximum's positions are: ",0
    newline db " ",10,0
    max_position dd 0
    
    ;point b)
    number_index dd 0
    permanent_length dd 0
    ok db 0
    
    ;point c)
    output_file_format db "binarynumbers.txt", 0
    
     ;for d)
    
    max_len dd 0
    len dd 0
    start_max dd 0
    start_pos dd 0
    index dd 0
    tmp_length dd 0
    hex_format db "%x ",0
    savedEDX dd 0
    savedEBX dd 0

    ;for e)
    divisor_format db "%d divisor's are: ",0
    

; our code starts here
segment code use32 class=code
    start:
        ;trying to open the  file
        ;fopen(file_path, access_mode)
        push dword access_mode
        push dword file_format
        call [fopen]
        add esp, 4*2
        
        cmp eax,0
        je ending
        
        mov [file_descriptor], eax
        
        mov edi, number_array
        
        ;we read one character at a time. If it's a digit, we add it to the number, if it's  a minus we 
        ;set the negative flag and if it is  a space we  add the number to the array and move on to the next number
        
        read_characters:
        ;fread(digit, 1, 1, file_descriptor)
        push dword [file_descriptor]
        push dword 1
        push dword 1
        push dword digit
        call [fread]
        add esp, 4*4
        
        
        
        cmp eax,0
        je point_a
        
        mov eax, dword[number]
        
        cmp byte[digit],20h ;ascii code of space
        je new_number
        
        cmp byte[digit],02Dh ;ascii code of '-'
        je negate 
        
        jmp add_digit ;if the character is neither a ' ' or a '-' it must be a digit
        
        new_number:
        ;we add the number to the array and 
        ;check if number is a negative one(neg_flag is 1)
        cmp byte[neg_flag],1
        je negate_number
        jmp pos_number
        negate_number:
        mov ebx,-1
        mul ebx
        pos_number:
        stosd ; storing the number into number_array
        add dword[array_length], 1
        mov byte[neg_flag], 0
        mov dword[number], 0
        
        jmp next_char
        negate:
        mov byte[neg_flag], 1
        jmp next_char
        
        add_digit:
        cmp eax, 0
        
        je single_digit
        jmp another_digit
        single_digit:
        
        sub byte[digit], '0'
        add eax, dword[digit]
        mov dword[number], eax

        jmp next_char
        
        another_digit:
        
        mov ebx, 10
        mul ebx
       
        sub byte[digit], '0'
        add eax, dword[digit]
        
        mov dword[number], eax

        
        next_char:
        
        jmp read_characters
        
        ;storing the last formed number
        
        
        
        point_a:
        
        ;sum, product,  maximum and the positions on which it  appears
        
        ;we compute the first element outside of the loop in order to initialise the maximum, sum and product
        
     
        mov eax, [number]
        stosd ; storing the number into number_array
        add dword[array_length], 1
        
        mov esi, number_array
        mov ecx, [array_length]
        
        lodsd 
        
        
        mov [max], eax
        add dword[sum], eax
        mov [number], eax
        mov eax, [product]
        imul dword [number]
        mov [product], eax
        
        sub ecx, 1
        
        sum_prod:
        lodsd
        add dword[sum], eax
        mov [number],  eax
        mov eax, [product]
        imul dword [number] 
        mov [product], eax
        
        mov eax, [number]
        
        cmp eax, [max]
        jg maxim
        jmp next_iter
        maxim:
        mov [max], eax
        next_iter:
        loop sum_prod
        
        ;print the sum, product and maximum
        
        ;printf("Sum is %d",sum)
        push dword [sum]
        push dword sum_format
        call [printf]
        add  esp, 4*2
        
        ;printf("Product is %d", product)
        push dword [product]
        push dword product_format
        call [printf]
        add esp, 4*2
        
        ;printf("Maximum is %d", max)
        push dword[max]
        push dword  max_format
        call [printf]
        add esp, 4*2
        
        push dword positions_format
        call [printf]
        add esp, 4
        
        ;printing the positions of the maximum
        ;now we find the positions of the maximum
       
       mov dword[max_position], 0 ;current counter
       mov ecx, [array_length]
       cld
       mov esi, number_array
       
       max_repeat:
       mov [savedECX], ecx
       lodsd
       cmp eax, [max]
       je show_position
       jmp next_position
       
       show_position:
       push dword [max_position]
       push dword print_format
       call [printf]
       add esp,  4*2
 
       next_position:
       add dword[max_position], 1
       
       mov ecx,  [savedECX]
       loop max_repeat
       
       push dword newline
       call [printf]
       add esp, 4
       
        ;b)	Sa se sorteze sirul de numere.
       
       mov eax, [array_length]
       mov [permanent_length], eax
       mov [number_index], eax
       
       
        bubble_sort: ;strictly increasing order -for doublewords
        
            mov byte[ok], 1
            mov esi, number_array
            mov dword[number_index], 0
            
            compare:
                
                mov ecx, dword[esi]
                mov edx, dword[esi + 4]
                cmp ecx,edx
                jle continue
              ;else interchange
                mov dword[esi], edx
                mov dword[esi + 4], ecx
                mov byte[ok], 0 ;at least one comparison has been made in the current loop
                
                continue:
                add esi, 4;array  of doublewords
                add dword[number_index], 1
                mov ecx, dword[permanent_length]
                sub ecx, 1
                cmp dword[number_index],  ecx
                
                jb compare
                cmp byte[ok], 0
                
               je bubble_sort
               
             
           mov esi,number_array

           
         
        
           ;printing the elements of the array
        mov esi, number_array
        mov ecx, [array_length]
        
           print_loop:
            lodsd
            ;printf("%d", eax)
            mov [savedECX], ecx
            push eax
            push dword print_format
            call [printf]
            add esp, 4*2
           
            mov ecx, [savedECX]
        
        loop print_loop
        
        ;add a newline
        push dword newline
       call [printf]
       add esp, 4
        
            
         ;c)	Sa se scrie sirul de numere in baza doi intr-un alt fisier.
         
         mov esi,number_array
         mov ecx, [permanent_length]
         
         ;TODO: for negative numbers, compute the two's complement in decimal (256 - number) 
           binary_convert:
           mov [savedECX], ecx
        lodsd
        cmp eax, 0
        jl  twos ;two's complement computed for negative numbers
        jmp next2
        twos:
        add eax, 256
        next2:
        push  eax
        push dword output_file_format
        call printBinary
        add esp, 4*2
        
        mov ecx,[savedECX]
        loop binary_convert

        
        ;d)	Sa se calculeze cel mai lung subsir de numere pare, afisati-l in baza 16.
      
      mov dword[start_pos], -1
        mov dword[index], 0
        mov ecx, [permanent_length]
        
        mov esi, number_array
        
        longestsubseq:
        lodsd ;v[i]
        mov bl,2
        idiv bl ;v[i]%2 -edx 
        cmp  ah,1
        jne even_elem
        jmp  odd_elem
        even_elem:
        cmp dword[start_pos], -1
        je init_start
        jmp increase_len
        
        init_start:
        mov edx, [index]
        mov [start_pos], edx
        mov dword[len], 1
        jmp next_iter_2
        
        increase_len:
        add dword[len], 1
        jmp next_iter_2
        odd_elem:
        mov edx,[len]
        cmp edx, [max_len]
        ja new_max
        jmp reinit
        new_max:
        mov [max_len], edx ;max_len = len
        mov edx, [start_pos]
        mov [start_max], edx ;start_max = start_pos
        
        reinit:
        mov dword [start_pos], -1
        mov dword [len], 0
        next_iter_2:
        add dword[index], 1
        
        loop longestsubseq
        
        ;testing for the last element
        mov edx,[len]
        cmp edx, [max_len]
        ja new_max1
        jmp print
        new_max1:
        mov [max_len], edx ;max_len = len
        mov edx, [start_pos]
        mov [start_max], edx ;start_max = start_pos
        
        print:
        
        
        ;printing the elements now
        mov ebx, number_array
        mov edx, [start_max]
        mov eax, 4
        mul edx
        mov edx, eax
        mov ecx, [max_len]
        
        print_even:
        
        mov eax, [ebx + edx]
        
        mov [savedEBX], ebx
        mov [savedECX], ecx
        mov [savedEDX], edx
        
        push eax
        push dword print_format
        call [printf]
        add esp, 4*2
        
        mov ebx, [savedEBX]
        mov ecx, [savedECX]
        mov edx, [savedEDX]
        
        add edx, 4
        loop print_even
        
        
        ;print a newline
        push dword newline
        call [printf]
        add esp, 4
        
         ;e)	Afisati divizorii numerelor neprime.
        mov esi, number_array
        mov ecx, [permanent_length]
        
        divisor_loop:
        mov [savedECX], ecx
        
        ;first we check if the number is not prime
        lodsd
        mov [savedEBX], eax
        push eax
        call PrimeCheck
        add esp, 4
        
        cmp eax,1
        jne is_not_prime
        jmp loopon
        
        jmp ending
        
        is_not_prime:
        
        push dword [savedEBX]
        push dword divisor_format
        call [printf]
        add esp, 4*2
        
        ;print the divisors
        ;to do-print divisors for a negative number
        cmp dword[savedEBX],0
        jl negative_number
        jmp divisors_show
        negative_number:
        mov eax,[savedEBX]
        mov ebx, -1
        mul ebx
        mov [savedEBX], eax
        divisors_show:
        push dword [savedEBX]
        call Divisors
        add esp, 4
        
        
        ;print a newline
        push dword newline
        call [printf]
        add esp, 4
        
        loopon:
        mov ecx, [savedECX]
        loop divisor_loop
        
        
        
        
        ending:
    
        ; exit(0)
        push    dword 0      ; push the parameter for exit onto the stack
        call    [exit]       ; call exit to terminate the program
