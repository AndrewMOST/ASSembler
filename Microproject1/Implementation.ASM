;��� ��� � ������� �� ���� �������� ��������,
;���������� ����� ����� ��������� �� ������� ������� ������������!
format PE console
entry start

include 'win32a.inc'

;--------------------------------------------------------------------------
section '.data' data readable writable

        strNum       db 'Input upper search boundary: ', 0
        strIncorSize  db 'Incorrect number input', 0
        strFermat     db 'Amount of Fermat numbers between 1 and entered number: %u', 10, 0
        strScanInt    db '%u', 0

        upper        dd 0
        prev         dd 0

;--------------------------------------------------------------------------
section '.code' code readable executable
start:
        call NumInput
        call Fermat
finish:
        call [getch]

        push 0
        call [ExitProcess]

;--------------------------------------------------------------------------
;��������� ������� ������� ������ �� �������, �������� �� � ���������� upper.
;��� ������������ ����� �������� �������-���������� failedNum.
;����� ���������� � ������� ebx -1 ��� �������� ���������� ����� �����.
;��� ���������� ����� ��������� ��������� � �������� �������������� ��������.
NumInput:
        push strNum
        call [printf]
        add esp, 4

        push upper
        push strScanInt
        call [scanf]
        add esp, 8

        mov eax, [upper]
        cmp eax, 0
        je  failedNum

        mov ebx, -1

        ret

;�����������, ���� ����� ��������� ����� ����� �� �������� ������ ����������
;��� ����� ����� ������ ������ ����������� (��� ����������� ������������).
;����� ����� ����� �� ������ �������� ������������ � ������� edi.
;��� ���������� � ������� ������������ ��������� ����� �����.
;������� ecx ������������ ��� ���������� ������ ������.
Fermat:
        inc ebx
        mov ecx, ebx
        mov edi, 1
        mov esi, 1

        shl esi, cl
        mov ecx, esi

        shl edi, cl
        inc edi

        ;���� ��������� ������������, ��������� � ������.
        cmp edi, [prev]
        jb DisplayNum

        ;��������� ����������� ����� ����� ����������� � ���������� temp.
        mov [prev], edi

        ;��������, ���� �� ���������� ��������� �����.
        cmp [upper], edi
        jae Fermat

;����� ������������� ���������� ����� �����.
DisplayNum:
        push ebx
        push strFermat
        call [printf]
        add esp, 8
        ret
;--------------------------------------------------------------------------
;����� ��������� � ������������ �����.
failedNum:
        push strIncorSize
        call [printf]
        call [getch]
        push 0
        call [ExitProcess]
;--------------------------------------------------------------------------
                                                 
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