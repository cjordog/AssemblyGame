
global mystart

sysc:
	int 80h
	ret

mystart:
	mov eax, [numNewLines]
printNewLine:
	push dword 1
	push dword newLine
	push dword 1
	mov eax, 4
	call sysc
	add esp, 12
	dec byte [numNewLines]
	cmp byte [numNewLines], 0
	jne printNewLine

	push dword 61
	push dword str5
	push dword 1
	mov eax, 4
	call sysc
	add esp, 12

	push dword 1
	push dword newLine
	push dword 1
	mov eax, 4
	call sysc
	add esp, 12

	push dword 61
	push dword str6
	push dword 1
	mov eax, 4
	call sysc
	add esp, 12

	push dword 61
	push dword str7
	push dword 1
	mov eax, 4
	call sysc
	add esp, 12

	push dword 61
	push dword str8
	push dword 1
	mov eax, 4
	call sysc
	add esp, 12

	push dword 1
	push dword newLine
	push dword 1
	mov eax, 4
	call sysc
	add esp, 12

	push dword 61
	push dword str9
	push dword 1
	mov eax, 4
	call sysc
	add esp, 12

	; read from stdin
	push dword 1				;  length of input
	push inputBuf				;  location
	push dword 0				;  read from stdin
	mov eax, 3					;  put write syscode in eax
    call sysc					;  syscall
    add esp, 12					;  clean up the stack

	; push dword 2
	; push dword str10
	; push dword 1
	; mov eax, 4
	; call sysc
	; add esp, 12
	; dec byte [countdown]
	; dec byte [str10]

gameStart:
	mov eax, [numNewLines]
printNewLine2:
	push dword 1
	push dword newLine
	push dword 1
	mov eax, 4
	call sysc
	add esp, 12
	dec byte [numNewLines]
	cmp byte [numNewLines], 0
	jne printNewLine2

delayReset:
	mov ecx, delayVal
delay:
	dec ecx
	cmp ecx, 0
	jne delay

	cmp byte [countdown], 0
	je endCountdown

	push dword 2
	push dword str10
	push dword 1
	mov eax, 4
	call sysc
	add esp, 12
	dec byte [countdown]
	dec byte [str10]
	jmp delayReset

endCountdown:
	push dword 4
	push dword str13
	push dword 1
	mov eax, 4
	call sysc
	add esp, 12

	;make stdin nonblocking
		; int flags = fcntl(fd, F_GETFL, 0);
		; fcntl(fd, F_SETFL, flags | O_NONBLOCK);

	push dword 0				;  third arg 
	push dword 3				;  F_GETFL flag for second arg
	push dword 0				;  0 for stdin first arg
	mov eax, 92					;  92 syscode for fcntl
	call sysc 					;  call syscall
	add esp, 12					;  clean up stack

	or eax, 4					;  or the current flags with O_NONBLOCK
	push eax					;  push the new flags on the stack for third arg
	push dword 4				;  4 for F_SETFL second arg
	push dword 0				;  0 for stdin first arg
	mov eax, 92					;  92 syscode for fcntl
	call sysc 					;  call fcntl
	add esp, 12					;  clean up the stack

gameLoop:
	; read from stdin
	push dword 1				;  length of input
	push inputBuf				;  location
	push dword 0				;  read from stdin
	mov eax, 3					;  put write syscode in eax
    call sysc					;  syscall
    add esp, 12					;  clean up the stack

	inc dword [timer]

	mov al, [currChar]
    cmp byte [inputBuf], al
    je correctChar
    jmp gameLoop

correctChar:
	inc byte [currChar]
	cmp byte [currChar], 123
	je finish
	jmp gameLoop

finish:
	;make stdin blocking again
		; int flags = fcntl(fd, F_GETFL, 0);
		; fcntl(fd, F_SETFL, flags & ~O_NONBLOCK);
	push dword 0				;  third arg 
	push dword 3				;  F_GETFL flag for second arg
	push dword 0				;  0 for stdin first arg
	mov eax, 92					;  92 syscode for fcntl
	call sysc 					;  call syscall
	add esp, 12					;  clean up stack

	xor eax, 4					;  make flags for blocking again
	push eax					;  push the new flags on the stack for third arg
	push dword 4				;  4 for F_SETFL second arg
	push dword 0				;  0 for stdin first arg
	mov eax, 92					;  92 syscode for fcntl
	call sysc 					;  call fcntl
	add esp, 12					;  clean up the stack

	push dword 15
	push dword str1
	push dword 1
	mov eax, 4
	call sysc
	add esp, 12

	push dword 12
	push dword str2
	push dword 1
	mov eax, 4
	call sysc
	add esp, 12
	mov edi, [timer]

printScoreSetup:
	mov eax, [printMask]
	mov dword [printMaskTemp], eax
	mov byte [printCounter], 0
printScore:
	mov eax, edi
	and eax, [printMaskTemp]
	cmp eax, 0
	je printZero
	jmp printOne
printZero:
	push dword [strLen]
	push dword zero
	push dword 1
	mov eax, 4
	call sysc
	add esp, 12
	jmp printLogic
printOne:
	push dword [strLen]
	push dword one
	push dword 1
	mov eax, 4
	call sysc
	add esp, 12
printLogic:
	inc byte [printCounter]
	shr dword [printMaskTemp], 1
	cmp byte [printCounter], 32
	je endPrint
	jmp printScore
endPrint:
	push dword 1
	push dword newLine
	push dword 1
	mov eax, 4
	call sysc
	add esp, 12
	inc byte [printNum]

	cmp byte [printNum], 1
	jne endPrintScore

	mov eax, [timer]
	cmp dword [highScore], eax
	jl dontUpdateHighScore
	mov eax, [timer]
	mov [highScore], eax

dontUpdateHighScore:
	mov edi, [highScore]
	
	push dword 12
	push dword str3
	push dword 1
	mov eax, 4
	call sysc
	add esp, 12
	jmp printScoreSetup

endPrintScore:
	push dword 36
	push dword str4
	push dword 1
	mov eax, 4
	call sysc
	add esp, 12

    ;reset variables
	mov dword [timer], 0
	mov byte [currChar], "a"
	mov byte [printNum], 0
	mov byte [countdown], 3
	mov byte [str10], "3"

playAgain:
	; read from stdin
	push dword 1				;  length of input
	push inputBuf				;  location
	push dword 0				;  read from stdin
	mov eax, 3					;  put write syscode in eax
    call sysc					;  syscall
    add esp, 12					;  clean up the stack

    cmp byte [inputBuf], "y"
    je gameStart
    cmp byte [inputBuf], 0xa	;  game writes an extra newline as soon as output finishes, so check to make sure it isnt that
    je playAgain
    jmp end

end:
	;exit
	push 0
	mov eax, 1
	call sysc

section .data

	delayVal equ 2000000000			; equ used for constants

	timer dd 0
	highScore dd 0x7FFFFFFF
	currChar db "a"
	countdown db 3

	printMask dd 0x80000000
	printMaskTemp dd 0
	printCounter db 0
	printNum db 0

	isRunning dd 1
	numLines dd 24
	paddleLoc dd 4
	strLen dd 1
	inputBuf: db 0

	zero db "0"
	one db "1"
	str1 db "Game Finished.", 0xa
	str2 db "Score:      "
	str3 db "High Score: "
	str4 db "Would you like to play again? [y/n]", 0xa
	str5 db "========================Typing Game======================== ", 0xa
	str6 db "Enter all letters, one at a time, in alphabetical order.    ", 0xa
	str7 db "Press enter after every letter. Try to get the fastest time.", 0xa
	str8 db "Press enter to begin...                                     ", 0xa
	str9 db "=========================================================== ", 0xa
	str10 db "3", 0xa
	str13 db "GO!", 0xa

	newLine db "", 0xa
	numNewLines db 40
