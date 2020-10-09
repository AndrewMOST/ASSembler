format PE console
entry start

include 'win32a.inc'

;--------------------------------------------------------------------------
section '.data' data readable writable

        strVecSize   db 'size of vector? ', 0
        strIncorSize db 'Incorrect size of vector = %d', 10, 0
        strVecElemI  db '[%d]? ', 0
        strScanInt   db '%d', 0
        strMinVal    db 'minimum value %d', 10, 0
        strVecElemOut  db '[%d] = %d', 10, 0

        vec_size     dd 0
        sum          dd 0
        help         dd ?
        min          dd ?
        i            dd ?
        tmp          dd ?
        tmpStack     dd ?
        vec          rd 1024
        vec2         rd 1024

;--------------------------------------------------------------------------
section '.code' code readable executable
start:
; 1) vector input
        call VectorInput
; 2) get vector sum
        call VectorSum
; 3) test vector out
        call VectorOut
finish:
        call [getch]

        push 0
        call [ExitProcess]

;--------------------------------------------------------------------------
VectorInput:
        push strVecSize
        call [printf]
        add esp, 4

        push vec_size
        push strScanInt
        call [scanf]
        add esp, 8

        mov eax, [vec_size]
        cmp eax, 0
        jle  failedSize
        cmp eax, 1024
        jg failedSize
; else continue...
getVector:
        xor ecx, ecx            ; ecx = 0
        mov ebx, vec

        mov [tmp], ebx
        ; input element
        mov [i], ecx
        push ecx
        push strVecElemI
        call [printf]
        add esp, 8

        push ebx
        push strScanInt
        call [scanf]
        add esp, 8

        mov eax, [ebx]
        mov [min], eax

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4

getVecLoop:
        mov [tmp], ebx
        cmp ecx, [vec_size]
        jge endInputVector       ; to end of loop

        ; input element
        mov [i], ecx
        push ecx
        push strVecElemI
        call [printf]
        add esp, 8

        push ebx
        push strScanInt
        call [scanf]
        add esp, 8

        mov eax, [ebx]
        cmp [min], eax
        call newMin

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp getVecLoop
endInputVector:
        push [min]
        push strMinVal
        call [printf]
        add esp, 8
        ret
;--------------------------------------------------------------------------
VectorSum:
        xor ecx, ecx            ; ecx = 0
        mov ebx, vec            ; ebx = &vec
        mov edx, vec2
sumVecLoop:
        ;mov [tmp], ebx
        cmp ecx, [vec_size]
        je endSumVector      ; to end of loop

        mov edi, [ebx]
        cmp edi, 0
        call comparer

        add ebx, 4
        add edx, 4
        inc ecx
        jmp sumVecLoop
endSumVector:
        ret
;--------------------------------------------------------------------------
VectorOut:
        mov [tmpStack], esp
        xor ecx, ecx            ; ecx = 0
        mov ebx, vec2           ; ebx = &vec
putVecLoop:
        mov [tmp], ebx
        cmp ecx, [vec_size]
        je endOutputVector      ; to end of loop
        mov [i], ecx

        ; output element
        push dword [ebx]
        push ecx
        push strVecElemOut
        call [printf]

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp putVecLoop
endOutputVector:
        mov esp, [tmpStack]
        ret
;--------------------------------------------------------------------------
failedSize:
        push vec_size
        push strIncorSize
        call [printf]
        push 0
        call [ExitProcess]
newMin:
        jle newMin_ret
        mov [min], eax
        newMin_ret:
        ret
comparer:
        je isnull
        mov [edx], edi
        ret
        isnull:
                mov edi, [min]
                mov [edx], edi
                ret
;-------------------------------third act - including HeapApi--------------------------
                                                 
section '.idata' import data readable
    library kernel, 'kernel32.dll',\
            msvcrt, 'msvcrt.dll',\
            user32,'USER32.DLL'

include 'api\user32.inc'
include 'api\kernel32.inc'
    import kernel,\
           ExitProcess, 'ExitProcess',\
           HeapCreate,'HeapCreate',\
           HeapAlloc,'HeapAlloc'
  include 'api\kernel32.inc'
    import msvcrt,\
           printf, 'printf',\
           scanf, 'scanf',\
           getch, '_getch'