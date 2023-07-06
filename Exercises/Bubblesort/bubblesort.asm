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
    ok db 1

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
            mov [aux2],ebx
            mov esi,0 ;index register
            bubble_sort:
              mov byte[ok], 1
              mov esi, 0
               compare:
               mov al,byte[aux2+esi]
               mov ah,byte [aux2+esi+1]
               cmp al,ah
               jae again
               ;perform the interchange
               mov byte[aux2+esi],ah
               mov byte[aux2+esi+1],al
               mov byte[ok], 0
               again:
               inc esi
               mov edx, 3
               cmp esi, edx
               jb compare
               cmp byte[ok], 0
            je bubble_sort
            
      mov ebx,dword[aux2]
      mov [d1+edi],ebx
      add edi,4
      dec ecx
  jnz secondloop
  
 
  
     
     

        ; exit(0)
        push    dword 0      ; push the parameter for exit onto the stack
        call    [exit]       ; call exit to terminate the program
