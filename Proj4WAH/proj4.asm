;************************************************************************************
; Program Name:	proj4.asm
; Programmer:	Austin Horne
; Class:		CSCI 2160
; Lab:			Proj4
; Date:			November 13, 2012
; Purpose:		Driver for project 4. Calls the external methods from myutility.asm.
;				Tests for invalid password characters upon return from the 
;				getpassword method.
;
;************************************************************************************

	.486
	.model flat
	include macros.asm
	
	.stack 100h	

	.data
	maxLength dword 12				;max length of the password
	strName byte 41 dup(?)			;string to hold the name input
	strWelcome byte "Welcome, ",0
	strThanks byte "Your number has been saved. Thank you and goodbye!",0
	strNamePrompt byte "What is your name? ",0
	strPwPrompt byte "What is your password? ",0
	strNumPrompt byte "Please enter a number. You may begin with a plus sign, minus",
						10,13,"sign, or digits 1-9: ",0
	strPwEntered byte "You entered: ",0
	strPass byte "Requirements met",0
	strRestrictions byte "The following restrictions were violated:",0
	strLengthError byte 9, "The length must be at least 6 characters long, but", 
			", no longer than the specified length",0
	strUpperError byte 9, "There must be at least 1 uppercase alphabetic character",0
	strLowerError byte 9, "There must be at least 1 lowercase alphabetic character",0
	strSpecialError byte 9, "There must be at least 1 special character of the list",
							" @!$#%*",0
	strFirstChError byte 9, "The first character MUST be an alphabetic character",
			" a-z, A-Z",0
	strNumericError byte 9, "There must be at least 1 numeric digit 0-9",0
	strInvalidChar byte 9, "Invalid character (not in A-Z, a-z, 0-9, @!$#%*)",0
	strPassword byte 13 dup(?)		;holds the password
	strNum byte 13 dup (?)			;holds the number obtained from getNum

	.code

_start:
	
	INVOKE putstring, addr strNamePrompt	;ask for a name
	INVOKE getstring, addr strName, 40		;get the name
newline										;newline macro
	INVOKE putstring, addr strWelcome		
	INVOKE putstring, addr strName			;greet the user
tryagain:
newline										;newline macro
	INVOKE putstring, addr strPwPrompt		;ask for a password

	push offset strPassword		;address of string to hold password
	push maxLength				;max length of the password
	call getpassword
	add esp, 8					;restore the stack pointer

newline
	INVOKE putstring, addr strPwEntered
	xor esi, esi		;index into strPassword
	
displayEntered:
	mov cl, strPassword[esi]	;move current character into cl
	cmp cl, 0
	je errors			;skip to testing when null found
putc cl
	inc esi				;next index in strPassword
	jmp displayEntered
	
errors:	
	cmp al, 0			;check to see if errors occurred
	jne tests	
newline			;no errors. print valid
	INVOKE putstring, addr strPass
newline
newline
	INVOKE putstring, addr strNumPrompt
	
	push maxLength	;maxLength = first parameter
	push offset strNum
	call getNum
	add esp, 8			;restore the stack pointer
	jmp terminate		;end of program
	
tests:	
newline		
	INVOKE putstring, addr strRestrictions
	
;test0	if error00 occurred (invalid length)
	test al, 00000001b			
	jnz printError0
	
test1:	;if error01 occurred (first char not alpha)
	test al, 00000010b			
	jnz printError1		
	
test2:	;if error02 occurred (no lowercase)
	test al, 00000100b			
	jnz printError2
	
test3:	;if error03 occurred (no uppercase)
	test al, 00001000b			
	jnz printError3
	
test4:	;if error04 occurred (no specials)
	test al, 00010000b
	jnz printError4
	
test5:	;if error05 occurred (no numerics)
	test al, 00100000b
	jnz printError5
	
test6:	;if error06 occurred (invalid character)
	test al, 01000000b
	jnz printError6
	jmp terminate
		
printError0:
newline
	INVOKE putstring, addr strLengthError
	jmp test1
	
printError1:
newline
	INVOKE putstring, addr strFirstChError
	jmp test2
	
printError2:
newline
	INVOKE putstring, addr strLowerError
	jmp test3
	
printError3:
newline	
	INVOKE putstring, addr strUpperError
	jmp test4
	
printError4:
newline
	INVOKE putstring, addr strSpecialError
	jmp test5
	
printError5:
newline
	INVOKE putstring, addr strNumericError
	jmp test6
	
printError6:
newline	
	INVOKE putstring, addr strInvalidChar
	
terminate:
	cmp al, 0		;check for errors occurred
	jne tryagain
	
newline
newline
	INVOKE putstring, addr strThanks
newline
	INVOKE ExitProcess, 0
	PUBLIC _start

	END
	
	
	
	
	
	
	
	
	
	
	