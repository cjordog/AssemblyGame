global mystart

sysc:
	int 80h 						;  int 80h is the instruction for syscall in freebsd
	ret

openHighScore:
	push dword [permissions] 		;  set up call for open 
	push dword [openFlags]
	push dword fileName
	mov eax, 5 						;  open has syscode 5
	call sysc
	add esp, 12 					;  clean up the stack
	mov dword [fd], eax  			;  move return value, file descriptor of highscores, into fd
	ret

closeHighScore:
	push dword [fd]
	mov eax, 6
	call sysc
	add esp, 4
	ret

clearHighScore:
	push dword 0
	push dword [fd]
	mov eax, 201
	call sysc
	add esp, 8
	ret

getFileSize: 						;  puts size of highscore.txt in fileSize
	push dword 2 					;  SEEK_END flag
	push dword 0 					;  offset in bytes from end
	push dword [fd]
	mov eax, 199 					;  syscode for LSEEK
	call sysc
	add esp, 12
	mov dword [fileSize], eax 		;  move file size (return value) to fileSize
	push dword 0 					;  SEEK_SET flag
	push dword 0 					;  offset in bytes from beginning
	push dword [fd]
	mov eax, 199 					;  syscode for LSEEK
	call sysc
	add esp, 12
	ret

readHighScore: 						;  reads high score into eax
continueRead:
	mov edi, 0 						;  use edi as counter, (edi not used by read)
	mov dword [highScore], 0 		;  reset score to 0 so we can read 
	mov eax, [printMask] 		
	mov dword [printMaskTemp], eax  ;  copy printMask into temporary alterable location
readLoop:
	push dword 1				;  length of input
	push inputBuf				;  location
	push dword [fd]				;
	mov eax, 3					;  put write syscode in eax
    call sysc					;  syscall
    add esp, 12					;  clean up the stack
    cmp byte [inputBuf], "0"
    je finishRead
	mov eax, [printMaskTemp]
	or dword [highScore], eax
finishRead:
	shr dword [printMaskTemp], 1
	inc edi
	cmp edi, 32
	jne readLoop
	ret

writeHighScore:	
	mov edi, [highScore]
	mov eax, [printMask] 		
	mov dword [printMaskTemp], eax;copy printMask into temporary alterable location
	mov byte [printCounter], 0  ;  reset counter to 0
printScore2:
	mov eax, edi  				;  move desired print value into eax
	and eax, [printMaskTemp]    ;  mask out all the other bits
	cmp eax, 0 					;  if the result is 0, print a 0, else print a 1
	je printZero2
	jmp printOne2
printZero2:
	push dword 1 					;  push length as 3rd arg for write
	push dword zero 				;  push address as 2nd arg for write
	push dword [fd]					;  
	mov eax, 4 						;  4 is syscode for write
	call sysc  						;  perform the syscall
	add esp, 12 					;  clean up the stack
	jmp printLogic2
printOne2:
	push dword 1 					;  push length as 3rd arg for write
	push dword one 					;  push address as 2nd arg for write
	push dword [fd]					;  
	mov eax, 4 						;  4 is syscode for write
	call sysc  						;  perform the syscall
	add esp, 12 					;  clean up the stack
printLogic2:
	inc byte [printCounter]		;  increment how many bits weve printed
	shr dword [printMaskTemp], 1;  shift our bit mask one bit to the right
	cmp byte [printCounter], 32 ;  if we have printed 32 bits exit the loop
	jne printScore2
	ret

	;put length in eax, string address in ebx
write:
	push eax 						;  push length as 3rd arg for write
	push ebx 						;  push address as 2nd arg for write
	push dword 1					;  push 1 for stdout
	mov eax, 4 						;  4 is syscode for write
	call sysc  						;  perform the syscall
	add esp, 12 					;  clean up the stack
	ret 							;  return to caller location

readByte:
	; read from stdin
	push dword 1				;  length of input
	push inputBuf				;  location
	push dword 0				;  read from stdin
	mov eax, 3					;  put write syscode in eax
    call sysc					;  syscall
    add esp, 12					;  clean up the stack
    ret

printNewLine:
	push dword 1					;  nBytes to print
	push dword newLine 				;  string to print
	push dword 1					;  print to stdout
	mov eax, 4						;  4 is syscode for write
	call sysc 						;  make the syscall
	add esp, 12						;  clean up the stack
	ret

clearScreen:
	mov edi, [numNewLines]			;  number of lines we want to print
printNL:
	call printNewLine 				;  print one newLine
	dec edi   			 			;  decrement our newLine counter
	cmp edi, 0						;  see if we have printed 
	jne printNL 					;  go back if we need to print another newLine
	ret

mystart:
	;write the start text
	call openHighScore			;  open the high score file
	call readHighScore
	cmp dword [highScore], -1
	jne cont
	mov dword [highScore], 0x7FFFFFFF
cont:
	call clearScreen			;  clear the screen
	mov eax, 61 				;  length of str5-str9 is 61
	mov ebx, str5
	call write
	call printNewLine
	mov eax, 61
	mov ebx, str6
	call write
	mov eax, 61
	mov ebx, str7
	call write
	mov eax, 61
	mov ebx, str8
	call write
	call printNewLine
	mov eax, 61
	mov ebx, str9
	call write

	call readByte

gameStart:
    call clearScreen

	; make stdin nonblocking
	; this allows for us to increment the timer while waiting for input
	; here is the c code that we want to write

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

delayReset:
	mov ecx, delayVal			;  put how long we want to delay into ecx
delay:
	dec ecx						;  keep decrementing ecx until its at 0
	cmp ecx, 0
	jne delay 					;  leave the loop when ecx is at 0

	cmp byte [countdown], 0 	;  if the countdown is at 0, start the game
	je endCountdown

	mov eax, 2
	mov ebx, str10
	call write 					;  print "3\n", "2\n", "1\n"
	dec byte [countdown]
	dec byte [str10]			;  decrement the ascii value in the string so we dont have to store many strings
	jmp delayReset 				;  if the countdown is not at 0, jump back to the delay

endCountdown:
	mov eax, 4
	mov ebx, str13				;  print "GO!"
	call write

gameLoop:
	call readByte

	inc dword [timer] 			;  increment the timer

	mov al, [currChar] 			;  put the current char that we are looking for into an 8 bit register
    cmp byte [inputBuf], al 	;  see if the last inputted character is the next character we want alphabetically
    je correctChar 				;  if it is the correct character, jump to the correctChar code
    jmp gameLoop 				;  otherwise jump back to reading for input

correctChar:
	inc byte [currChar] 		;  increment the character were looking for next
	cmp byte [currChar], 123    ;  if we just typed "z"
	je finish 					;  jump to end code
	jmp gameLoop				;  otherwise go back to input loop

finish:
	; make stdin blocking again,
	; since we no longer need to simultaneously update timer
	; here is the c code we want 

		; int flags = fcntl(fd, F_GETFL, 0);
		; fcntl(fd, F_SETFL, flags & ~O_NONBLOCK);

	push dword 0				;  third arg 
	push dword 3				;  F_GETFL flag for second arg
	push dword 0				;  0 for stdin first arg
	mov eax, 92					;  92 syscode for fcntl
	call sysc 					;  call syscall
	add esp, 12					;  clean up stack

	xor eax, 4					;  setup flags for blocking again
	push eax					;  push the new flags on the stack for third arg
	push dword 4				;  4 for F_SETFL second arg
	push dword 0				;  0 for stdin first arg
	mov eax, 92					;  92 syscode for fcntl
	call sysc 					;  call fcntl
	add esp, 12					;  clean up the stack

	mov eax, 15
	mov ebx, str1 			   	;  write "Game Finished."
	call write

	mov eax, 12
	mov ebx, str2 			   	;  write "Score: "
	call write
	mov edi, [timer] 			;  want timer in edi so we can print it

printScoreSetup: 				;  printScore prints a 32 bit integer value, held in edi
	mov eax, [printMask] 		
	mov dword [printMaskTemp], eax;copy printMask into temporary alterable location
	mov byte [printCounter], 0  ;  reset counter to 0
printScore:
	mov eax, edi  				;  move desired print value into eax
	and eax, [printMaskTemp]    ;  mask out all the other bits
	cmp eax, 0 					;  if the result is 0, print a 0, else print a 1
	je printZero
	jmp printOne
printZero:
	mov eax, [strLen]
	mov ebx, zero		   		;  print a '0' and return to print loop
	call write
	jmp printLogic
printOne:
	mov eax, [strLen]
	mov ebx, one		   		;  print a '1' and return to print loop
	call write
printLogic:
	inc byte [printCounter]		;  increment how many bits weve printed
	shr dword [printMaskTemp], 1;  shift our bit mask one bit to the right
	cmp byte [printCounter], 32 ;  if we have printed 32 bits exit the loop
	je endPrint
	jmp printScore
endPrint:
	call printNewLine			
	inc byte [printNum] 		;  counter used for printing both current score and local score

	cmp byte [printNum], 1
	jne endPrintScore 			;  if we printed 2 scores already, finish printing

	mov eax, [timer] 			;  move timer value for comparison
	cmp dword [highScore], eax  ;  compare high score to current score
	jl dontUpdateHighScore 		;  if the high score is less than current, dont do anything, otherwise update the high score
	mov eax, [timer]
	mov [highScore], eax

dontUpdateHighScore:
	mov edi, [highScore] 		;  move the high score into edi for printing, since we have not yet printed it
	
	mov eax, 12
	mov ebx, str3 				;  print "High Score: "
	call write 
	jmp printScoreSetup 		;  print actual number high score

endPrintScore:
	mov eax, 36
	mov ebx, str4
	call write

    ;reset variables
	mov dword [timer], 0
	mov byte [currChar], "a"
	mov byte [printNum], 0
	mov byte [countdown], 3
	mov byte [str10], "3"

playAgain:
	call readByte

    cmp byte [inputBuf], "y" 	;  if they input y, start over game
    je gameStart
    cmp byte [inputBuf], 0xa	;  game writes an extra newline as soon as output finishes, so check to make sure it isnt that
    je playAgain
    jmp end

end:
	call clearHighScore
	call writeHighScore
	call closeHighScore
	;exit
	push dword 0  				;  exit with status 0
	mov eax, 1 					;  1 is syscode for exit
	call sysc



section .data
	; NOTE: equ used for constants
	delayVal equ 2000000000			;  how much delay on countdowns

	timer dd 0						;  current game timer
	highScore dd 0x7FFFFFFF			;  high score, stored in binary
	currChar db "a" 				;  current character that we want to read in
	countdown db 3 					;  countdown counter for beginning

	printMask dd 0x80000000 		;  bitmask for printing 32 bit binary score
	printMaskTemp dd 0 				;  temporary storage for editing printmask
	printCounter db 0 				;  how many bits have we printed
	printNum db 0 					;  count how many numbers weve printed (so we can reuse code)

	strLen dd 1 					;  length of certain strings
	inputBuf: db 0 					;  input buffer for reading in 

	;strings

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

	permissions dd 511
	fileName db "highscores.txt", 0x0
	openFlags dd 514
	fd dd 0
	fileSize dd 0

	newLine db "", 0xa
	numNewLines db 40