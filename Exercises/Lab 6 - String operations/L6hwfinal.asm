;An array of words is given. Write an asm program in order to obtain an array of doublewords, where each doubleword will contain each nibble unpacked ;on a byte (each nibble will be preceded by a 0 digit), arranged in an ascending order within the doubleword.
bits 32 ; assembling for the 32 bits architecture

; declare the EntryPoint (a label defining the very first instruction of the program)
global start        

; declare external functions needed by our program
extern exit               ; tell nasm that exit exists even if we won't be defining it
import exit msvcrt.dll    ; exit is a function that ends the calling process. It is defined in msvcrt.dll
                          ; msvcrt.dll contains exit, printf and all the other important C-runtime specific functions

; our data is declared here (the variables needed by our program)
segment data use32 class=data
    a dw 5228h ,137Ah, 5238h, 9AFCh,9A00h, 6935h
    l1 equ ($-a)/2
    d1 times l1 dd 0
    d2 times l1 dd 0
    maxd3 times l1 dd 0
    indexesi dd 0
    indexedi dd 0
    auxecx1 dd 0
    cont dd 0
    pivot db 0 
    aux db 0
    min1 db 0
    aux2 times l1 dd 0
    a1 dw 0
    daux dd 0
    copyedx dd 0

; our code starts here
segment code use32 class=code
    start:
    
    mov ecx,l1
 
    mov esi,0
    mov edi,0
    
    mainloop:
     ;here we form the doubleword where each byte has the form 0a, where a is a digit from the initial word
        
        mov ax,[a+esi]
        mov [indexesi],esi
        mov [a1],ax
        mov esi,a1
        mov ebx,0; the final doubleword is stored in ebx
        ;our current word is stored in a1
        ;we transform the low byte of our word: ab ,into 0a0b 
        lodsb ;
        ; 
        mov dl,al
        and al, 00001111b ;isolate the low part of the byte
        shl ebx,8
        cbw
        cwde ;
       ; or EAX, 1111111100000000b ;EAX = 1104h
        or EBX,EAX ; we add the 0a byte to the doubleword  
      
        ; 
        mov al,dl ; 
        shr al,4 ; isolate the high part of the low byte
        shl ebx,8 ;make room for it in ebx
        cbw
        cwde
        or EBX,EAX ;add it to ebx 
        
        ;now we transform the high byte in the same way
        lodsb ;
        
       
        mov dl,al
        and al, 00001111b ; 
        shl ebx,8
        cbw
        cwde ;al -> eax: 000ah
       ; or EAX, 1111111100000000b ;EAX = 110ah
        or EBX,EAX ; EBX = 0...0 0ah        
      

        mov al,dl ; al = 34h
        shr al,4 ; al = 03h
        shl ebx,8
        cbw
        cwde
        or EBX,EAX
        
        ;final doubleword stored in ebx
      
      mov esi,[indexesi] 
      mov [d1+edi],ebx ;add the final doubleword in the first destination string
      add edi,4 ;working with doublewords
      add esi,2 ;working with words    
            
    loop mainloop
    
   ; mov ecx,l1
    ;mov edi,0
   
    
    ;we have built the array with numbers 0a0b0c0d - now we need to have the digits sorted
    
    mov ecx,l1
    ;mov esi,0
    mov edi,0
   
    
    secondloop:
         mov ebx,[d1+edi] ;each doubleword from d1 is stored in ebx
        ; mov [indexesi],esi
        mov [auxecx1],ecx
         mov edx,0
         mov ecx,4
        do:
            mov [copyedx],edx
            mov [cont],ecx
           ; mov ecx,0Fh
           ; mov [min1],ecx
            mov ecx,4
            mov [pivot],dl
            mov [aux2],ebx
            mov esi,aux2
           ; lodsb ;low byte of ebx, 09
            mov byte[min1],00h
         ;min1 has to have the highest byte of the doubleword
         ;make an array of doublewords where each doubleword consists of the highest value byte from each doubleword         
             sort:
               
               lodsb 
               cmp al,[min1];if al < min1, min1 = al, else: checks next byte
               ja minim
               jmp endsort
               minim:
               cmp al,00h
               jne propermin
               jmp endsort
               propermin:
               mov [min1],al
            endsort:
            loop sort
            
            ;we remove from ebx the byte we have just sorted
            
                mov al,[min1]
                cbw
                cwde
                mov edx,ebx
                
                and edx,0000000FFh
                cmp edx,eax
                
                je comp1
                jne next1
                comp1: 
                ;or EDX, 000000000h
                ;jz next1
                and EBX,0FFFFFF00h
                jmp endsort2
                
                next1:
                rol eax,8
                mov edx,ebx
                
                and edx,00000FF00h
                cmp edx,eax
                
                je comp2
                jne next2
                comp2: 
                ;or EDX, 000000000h
                ;jz next2
                and EBX,0FFFF00FFh
                jmp endsort2
                
                next2:
                rol eax,8
                mov edx,ebx
                
                and edx,000FF0000h
                cmp edx,eax
                
                je comp3
                jne next3
                comp3: 
                ;or EDX, 000000000h
                ;jz next3
                and EBX,0FF00FFFFh
                jmp endsort2
                
                next3:
                rol eax,8
                mov edx,ebx
                
                and edx,0FF000000h
                cmp edx,eax
                
                je comp4
                jne add0
                comp4: 
               ; or EDX, 000000000h
               ; jz endsort2
                and EBX,000FFFFFFh
                jmp endsort2
               ;if we reached this point, it means that our element is 00
               add0:
                mov byte[min1],00b
            
            endsort2:
            mov al,[min1]
                cbw
                cwde
            mov ecx,[cont]
            mov edx,[copyedx]
            rol EDX,8
            or EDX,EAX
        dec ecx
        jnz do
         
     
      mov ecx,[auxecx1]         

      mov [d2+edi],edx
      add edi,4
      dec ecx
  jnz secondloop
  
  ;we have sorted the bytes of each doubleword in descending order so now we reverse them 
  mov edi, 0
 ; std; we store the bytes of the doublewords in reverse order so DF = 1
  mov ecx,l1
  
  reverse:
     mov [copyedx], ecx
     mov ecx,4
     mov ebx,0
     mov edx,[d2+edi]
     mov [aux2],edx
     mov esi,aux2
    
     ;we form in ebx the doubleword formed from bytes in descending order
     descending_byte:
     lodsb
     cbw
     cwde
     or ebx,eax ;store the byte in the doubleword
     rol ebx,8 ;make room for the other byte
     loop descending_byte
   
     ror ebx,8
     mov [d1+edi], ebx
     add edi,4
     mov ecx,[copyedx]
  loop reverse
     
     

        ; exit(0)
        push    dword 0      ; push the parameter for exit onto the stack
        call    [exit]       ; call exit to terminate the program
