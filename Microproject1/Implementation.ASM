;Так как в задании не было замечено обратное,
;количество чисел Ферма считается до верхней границы включительно!
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
;Считывает верхнюю границу поиска из консоли, сохраняя ее в переменную upper.
;При некорректном вводе вызывает функцию-обработчик failedNum.
;Затем записывает в регистр ebx -1 для подсчета количества чисел Ферма.
;При корректном вводе программа переходит к подсчету запрашиваемого значения.
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

;Итерируется, пока новое найденное число Ферма не окажется больше введенного
;или новое число станет меньше предыдущего (так проверяется переполнение).
;Новое число Ферма на каждой итерации записывается в регистр edi.
;Для возведения в степень используется побитовый сдвиг влево.
;Регистр ecx используется для корректной работы сдвига.
Fermat:
        inc ebx
        mov ecx, ebx
        mov edi, 1
        mov esi, 1

        shl esi, cl
        mov ecx, esi

        shl edi, cl
        inc edi

        ;Если произошло переполнение, переходит к выводу.
        cmp edi, [prev]
        jb DisplayNum

        ;Последнее вычисленное число Ферма сохраняется в переменную temp.
        mov [prev], edi

        ;Итерация, пока не превзойдем введенное число.
        cmp [upper], edi
        jae Fermat

;Вывод подсчитанного количества чисел Ферма.
DisplayNum:
        push ebx
        push strFermat
        call [printf]
        add esp, 8
        ret
;--------------------------------------------------------------------------
;Вывод сообщения о некорректном вводе.
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