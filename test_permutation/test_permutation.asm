format PE console
include 'c:\fasm\include\win32ax.inc'
include 'c:\fasm\include\macro\proc32.inc'

section '.data' Data readable writeable
  outhandle  dd ?
  inhandle   dd ?
  numwritten dd ?
  inchar     rb 3
  numread    dd ?
  num        dd ?
  perm       rd 10
  str1       rb 100

section '.text' code executable 
start:
 invoke	FreeConsole
 invoke	AllocConsole
 invoke	GetStdHandle, STD_OUTPUT_HANDLE
 mov	[outhandle],eax
 invoke	GetStdHandle, STD_INPUT_HANDLE
 mov	[inhandle],eax

 invoke	WriteConsole,[outhandle],"Enter number of elements (1-9): ",32,numwritten,0
 invoke	ReadConsole,[inhandle],inchar,3,numread,0

 cmp	[numread],3
 jne	error
 movzx	ecx,[inchar]
 sub	cl,'0'
 jz	error
 cmp	cl,9
 ja	error
 mov	[num],ecx
 cld
 xor	eax,eax
 mov	edi,perm
@1:
 stosd
 inc	eax
 loop	@1

next:
 mov ecx,[num]
 mov esi,perm
 mov edi,str1
 cld
@2:
 lodsd
 add al,'0'
 stosb
 loop @2
 mov ax,0a0dh
 stosw
 mov byte [edi],0

 mov eax,[num]
 add eax,2
 invoke	WriteConsole, [outhandle], str1, eax, numwritten, 0

 stdcall Next_permutation, perm, [num]
 or eax,eax
 jnz next

 invoke	ReadConsole, [inhandle], inchar, 2, numread, 0

error:
 invoke	ExitProcess,0

proc Next_permutation stdcall, m:DWORD, n:DWORD
 local max dd ?, numbesp dd ?, indmax dd ?, list dd m1

m1:
m2: 
 mov edi,0           ; edi = i1
 mov eax,[n]
 dec eax
 mov esi,eax         ; esi = i2
 mov [max],eax
 mov ebx,[m]         ; ebx = m
.while1:
 cmp edi,esi
 jae .endwhile1
.m1:
  mov [numbesp],0
  mov edx,edi        ; edx = i
.for1:
  cmp edx,esi 
  jae .endfor1
  mov eax,[ebx+edx*4]
  cmp eax,[max]
  jae .endif1
   lea ecx,[edx+1]   ; ecx = j
.for2:
    cmp ecx,esi
    ja .endfor2
    mov eax,[ebx+ecx*4]
    cmp eax,[ebx+edx*4]
    jae .endif2
     inc [numbesp]
.endif2:
    inc ecx
    jmp .for2
.endfor2:
.endif1:     
   inc edx
   jmp .for1
.endfor1:
   mov ecx,edi       ; ecx = i
.for3:
   cmp ecx,esi
   ja .endfor3
   mov eax,[ebx+ecx*4]
   cmp eax,[max]
   je .m2
.endif3:
   inc ecx
   jmp .for3
.endfor3:
.m2:
   mov [indmax],ecx
   test byte [numbesp],1
   jz .endif4
   cmp [indmax],esi
   je .endif5
    mov ecx,[indmax]
    mov eax,[ebx+ecx*4+4]
    mov [ebx+ecx*4],eax
    mov eax,[max]
    mov [ebx+ecx*4+4],eax
    mov eax,1
    jmp .exit
.endif5:
   dec [max]
   dec esi
   jmp .m1
.endif4:
  cmp [indmax],edi
  je .endif6
   mov ecx,[indmax]
   mov eax,[ebx+ecx*4-4]
   mov [ebx+ecx*4],eax
   mov eax,[max]
   mov [ebx+ecx*4-4],eax
   mov eax,1
   jmp .exit
.endif6:
 dec [max]
 inc edi
 jmp .while1
.endwhile1:
 xor eax,eax
.exit:
 ret
endp

.end start
