bits 32

global in_array
global number_of_apparitions_in_file

extern fread, fopen, fclose, printf
import fread msvcrt.dll                        
import fopen msvcrt.dll
import fclose msvcrt.dll
import printf msvcrt.dll


segment data use 32
read_mode db "r",0
char_read db 0
file_descriptor dd 0
my_char db 0
counter dd 0
segment code use 32

number_of_apparitions_in_file:

   mov ebx, [esp+4]
   mov eax,[esp+8];the character
   mov [my_char], al
   
   ;opening the file
   push dword read_mode
   push dword ebx
   call [fopen]
   add esp, 4*2
   
   cmp eax,0
   je ending
   
   mov dword[counter],0
   mov [file_descriptor], eax
   ;mov ecx, 0;counter for frequency of given char
   
   read_chars:
   ;fread(char_read,1,1,file_descriptor)
   push dword [file_descriptor]
   push dword 1
   push dword 1
   push dword char_read
   call [fread]
   add esp, 4*4
   
   cmp eax,0
   je out_of_this
   
   mov al,[my_char]
   cmp al, [char_read]
   je increase
   jmp read_chars
   
   increase:
   add dword[counter], 1
   jmp read_chars
   
   out_of_this:
   mov eax, [counter]

    ending:
    ret