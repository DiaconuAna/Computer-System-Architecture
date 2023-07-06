bits 32
global is_letter
global caesar_cipher


segment data use 32

segment code use 32
is_letter:
    ;checks  if a given character is a letter
    mov eax, [esp+4]
    ; the character is stored in the lower byte, al
    ;we first check if it's a lowercase letter
    cmp al,'a'
    jae next_lower
    jmp upper
    next_lower:
    cmp al,'z'
    jbe letter
    
    upper:
    ;if it's not lowercase, it may be uppercase
    cmp al,'A'
    jae next_upper
    jmp not_letter
    next_upper:
    cmp al,'Z'
    jbe letter
    jmp not_letter
    
    
    
    letter:
    mov eax,1
    ret
    
    not_letter:
    mov eax,0
    ret
   
   
caesar_cipher:
    ; ABCDâŚ WXYZ -> CDEFâŚ  YZAB
    mov  eax, [esp+4]
    ;the character (which we already know is a letter) is stored in al
    cmp al,'z'
    je z1
    cmp al,'Z'
    je z2
    cmp al,'y'
    je y1
    cmp al,'Y'
    je y2
    add al, 2
    jmp ending
    
    z1:
    mov al,'b'
    jmp ending
    
    z2:
    mov al,'B'
    jmp ending
    
    y1:
    mov  al,'a'
    jmp ending
    
    y2:
    mov al,'A'
    jmp ending
    
    
    
    ending:
    ret