;************************************************************************************
; Program Name:	myutility.asm
; Programmer:	Austin Horne
; Class:		CSCI 2160
; Lab:			Proj4
; Date:			November 13, 2012
; Purpose:		Contain certain utility methods which could be used for multiple
;				projects. 
;				Contains:
;						getPassword
;						stringLength
;
;************************************************************************************

	.486
	.model flat
	extern getchar:near32, putchar:near32
	.stack 100h	

	.data
;COMMENT!
;/***********************************************************************************
; * Name: putc
; * Date: 11/9/12
; * Purpose: To display a character on the screen. Calls the putchar method from 
;			Utility201211.obj
; * Parameters:
;		@param char:byte
;************************************************************************************
;!
putc macro char 
	push eax		;;preserve eax
	mov al, char	;;get the character passed into AL for the putchar procedure
	push eax		;;pass parameter to putchar
	call putchar 
	add esp, 4		;;restore stack pointer
	pop eax			;restore eax
endm

;COMMENT!
;/************************************************************************************
; * Name: getc
; * Date: 11/9/12
; * Purpose: To get a character from the keyboard. Calls the getchar method from 
;			Utility201211.obj
; * Parameters:
;		@param char:byte
;************************************************************************************
;!
getc macro char
	push eax		;preserve register
	
	call getchar
	mov char, al	;get the returned character into the parameter
	
	pop eax			;restore register	
endm
	.code
	
;COMMENT !
;/***********************************************************************************
; * Method Name: getPassword
; * Method Purpose: get a password from the keyboard up to a max length passed as the
; * 				   second parameter. Display an asterisk for every character 
; *				   entered. Test the password for correct values. Disallows any
; *				   character not in the set [a-z],[A-Z],[0-9], or [!@#$%*]. First 
; * 				   character must be alphabetical. Password must contain 1 
; *				   lowercase alpha, 1 uppercase alpha, 1 digit, and 1 special.
; *
; * Date created: 11/5/2012
; * Date last modified: 11/12/2012
; *
; * Parameters:	
; *		@param lpPassword:dword	[ebp+12]
; *		@param dMaxLength:dword	[ebp+8]
; ***********************************************************************************
; !
 
getpassword PROC

	push ebp		;preserve the base pointer
	mov ebp, esp	;set the stack frame
	push ebx		;ebx used to reference starting address of strPassword
	push ecx		;ecx used to look at strPassword byte by byte (cl)
	push edi		;edi used as a counter
	push esi		;stores the length of the password entered

	sub esp, 4		;reserve space for local variable	
minLength_Local equ dword ptr [ebp-16]	;holds minimum password legnth.
	mov minLength_Local, 6	;the minimum password legnth allowed

asterisk equ 02Ah	
backspace equ 08h	;labels for ascii key codes
enterkey equ 0Dh
space equ 020h

pwLength equ [ebp+8]	;the length parameter
	mov ebx, [ebp+12]	;starting address of the string to hold
	xor edi, edi		;edi  = character counter, starting at 0

getInput:	
	call getchar		;get character for the password
	cmp al, enterkey			;check for enter key
	je done
	cmp al, backspace			;check for backspace pressed
	je backspacePressed
	cmp edi, pwLength	;if password has reached length limit
	je getInput			;go back to beginning
	
putc asterisk			;display an asterisk	
	mov [ebx+edi], al	;move input character into current index in string
	inc edi				;count 1 character
	jmp getInput		;get more characters after asterisk displayed
	
backspacePressed:
	cmp edi, 0			;check to see if character count = 0
	je getInput
	dec edi				;-1 from character count
putc backspace			;move back one space
putc space				;overwrite character with a space
putc backspace			;move cursor back after overwrite
	jmp getInput
	
done:					;enter key pressed. finished getting characters
	xor al, al
	mov [ebx+edi], al 	;null-terminate the string
	push ebx			;beginning address of the password
	call stringLength		;use the stringLength method to check the length of the
							;password that the user entered
	add esp, 4				;restore stack pointer
	mov esi, eax			;store the string length in esi so eax can be cleared
	xor eax, eax			;prime al to hold error check

;error00	length requirements not met
	cmp esi, minLength_Local	;check for minimum length
	jl error0fail
	cmp esi, pwLength			;check for length greater than specified
	jg error0fail
	
error01:	;first character not alphabetic
	mov ecx, [ebx]
	test cl, 10000000b		;check for 80h and above
	jnz error1fail
	test cl, 01000000b		;test for character code from 40h to 7Fh
	jz error1fail
	test cl, 00011111b		;test for character code 60h or 40h
	jz error1fail
	test cl, 00010000b		;test for character code 50h-5Fh or 70h-7Fh
	jz error02				;skip to next error check if not
	test cl, 00001000b		;test for 58-5F or 78-7F
	jz error02				;skip to next error check if not
	test cl, 00000100b		;test for 5C-5F or 7C-7F
	jnz error1fail			;if 5C-5F or 7C-7F, fail test
	test cl, 00000010b		;test for 5A-5B or 7A-7B
	jz error02				;if not, allow and skip to next error check
	test cl, 00000001b		;check for 5B or 7B
	jnz error1fail	
	
error02:	;check for lowercase alpha
	mov edi, -1
	
beginning02:
	inc edi					;counter + 1
	cmp edi, esi			;counter reached the length of the password?
	je error2fail			;only reached when no lowercase alphas are found
	mov ecx, [ebx+edi]		;ecx --> value at address in strPassword[edi]
	test cl, 01000000b		;between 40h - 7Fh
	jz beginning02			;check next character
	test cl, 00100000b		;60h-7Fh?
	jz beginning02			;check next character
	test cl, 00011111b		;60h?
	jz beginning02			;check next
	test cl, 00010000b		;70h-7Fh?
	jz error03				;if 61h-6Fh (lowercase alpha), skip to next error check
	test cl, 00001111b		;70h?
	jz error03				;if 70h (lowercase p), skip to next
	test cl, 00001000b		;78h-7Fh?
	jz error03				;if 70h-77h (lowercase alpha), skip to next error check
	test cl, 00000100b		;7C-7Fh?
	jnz beginning02			;Yes, check next
	test cl, 00000010b		;7A-7B?
	jz error03				;No, skip to next error check
	test cl, 00000001b		;7A?
	jz error03				;if 7Ah (lowercase alpha), skip to next error check
	jmp beginning02			;check next
	
error03:	;check for uppercase alpha
	mov edi, -1
beginning03:
	
	inc edi					;counter + 1
	cmp edi, esi			;counter reached the length of the password?
	je error3fail			;only reached when no uppercase alphas are found
	mov ecx, [ebx+edi]		;ecx --> value at address in strPassword[edi]
	test cl, 01000000b		;40h-7Fh?
	jz beginning03			;No. check next
	test cl, 10111111b		;40h?
	jz beginning03			;Yes. Check next
	test cl, 00100000b		;60h-7Fh?
	jnz beginning03			;Yes. check next
	test cl, 00010000b		;50h-5Fh?
	jz error04				;Not 50 - 5F. Uppercase found, skip next
	test cl, 00001000b		;58h - 5Fh?
	jz error04				;not 58h -5Fh. Uppercase, skip.
	test cl, 00000100b		;5C - 5F?
	jnz beginning03			;5C - 5F, check next
	test cl, 00000010b		;5A-5B?
	jz error04				;No. Uppercase, skip
	test cl, 00000001b		;5B?
	jz error04				;No, 5A. passed
	jmp beginning03
	
	
error04:		;check for special character @!$#%*
	mov edi, -1
beginning04:
	
	inc edi					;counter + 1
	cmp edi, esi			;counter reached the length of the password?
	je error4fail			;only reached when no special characters are found
	mov ecx, [ebx+edi]		;ecx --> value at address in strPassword[edi]
	test cl, 11011101b		;22h (") or 20h ( )?
	jz beginning04			;Yes. not special. check next character
	test cl, 10111111b		;40h (@)?
	jz error05				;Yes. Skip to next test
	test cl, 11011110b		;21h (!)?
	jz error05				;Yes. Skip to next test
	test cl, 11011011b		;24h ($)?
	jz error05				;Yes. Skip to next test
	test cl, 11011100b		;23h (#)?
	jz error05				;Yes. Skip to next test
	test cl, 11011010b		;25h (%)?
	jz error05				;Yes. Skip to next test
	test cl, 11010101b		;28h or 2Ah (*)?
	jz bit1check			;Yes, check to see which one
	jmp beginning04			;if no special characters found, check next character

bit1check:
	test cl, 00000111b		;28h?
	jz beginning04			;Yes. No special character found, back to check next
	jmp error05				;Only reached when character is 2Ah (*)
	
error05:		;check for numerics
	mov edi, -1	
beginning05:
	inc edi					;counter + 1
	cmp edi, esi			;counter reached the length of the password?
	je error5fail			;only reached when no numerics are found
	mov ecx, [ebx+edi]		;ecx --> value at address in strPassword[edi]
	test cl, 11000000b		;character code > 3Fh?
	jnz beginning05			;Yes. check next
	test cl, 00100000b		;character code < 20h?
	jz beginning05			;Yes. check next
	test cl, 00010000b		;character code < 30h?
	jz beginning05			;Yes. check next
	test cl, 00001000b		;38h-3Fh?
	jz error06				;No. Passed numeric test
	test cl, 00000100b		;3Ch-3Fh?
	jnz beginning05			;Yes. check next
	test cl, 00000010b		;3Ah-3Bh?
	jnz beginning05			;Yes check next
	jmp error06				;is 30-39. passed test
	
error06:		;check for invalid characters
	mov edi, -1	
beginning06:
	inc edi					;counter + 1
	cmp edi, esi			;counter reached the length of the password?
	je exit					;only reached when no invalid characters are entered
	mov ecx, [ebx+edi]		;ecx --> value at address in strPassword[edi]
	test cl, 11011101b		;22h (") or 20h ( )?
	jz error6fail			;Yes. invalid character
	test cl, 11110000b		;0h-09h?
	jz error6fail			;Yes. invalid character
	test cl, 11100000b		;10h-1Fh?
	jz error6fail			;Yes. invalid character
	test cl, 11010000b		;20h-2Fh?
	jz bit5					;yes. jump to check
	test cl, 11000000b		;30h-3Fh?
	jz bit4and5				;yes. just to check
	test cl, 00010000b		;50h-5Fh or 70h-7Fh?
	jnz bit4				;yes, check
	test cl, 10011111b		;40h or 60h?
	jnz beginning06			;No. check next
	test cl, 00100000b		;60h?
	jnz error6fail			;Yes. fail test!
	jmp beginning06			;check next
	
bit5:
	test cl, 11010111b		;28h (?
	jz error6fail			;yes, fail test
	test cl, 11011110b		;21h (!)?
	jz beginning06			;Yes. Skip to next test
	test cl, 11011011b		;24h ($)?
	jz beginning06			;Yes. Skip to next test
	test cl, 11011100b		;23h (#)?
	jz beginning06			;Yes. Skip to next test
	test cl, 11011010b		;25h (%)?
	jz beginning06			;Yes. Skip to next test
	test cl, 11010101b		;2Ah (*)
	jz beginning06			;Yes. Skip to next test
	jmp error6fail			;failed test
	
bit4and5:
	test cl, 00001000b		;38-3Fh?
	jz beginning06			;No. check next
	test cl, 00000100b		;3Ch-3Fh?
	jnz error6fail			;yes, fail test
	test cl, 00000010b		;3Ah-3Bh?
	jnz error6fail			;yes, fail test
	jmp beginning06			;check next
	
bit4:
	test cl, 00001000b		;58h-5Fh or 78h-7Fh?
	jz beginning06			;No. check next
	test cl, 00000100b		;5Ch-5Fh or 7Ch-7Fh?
	jnz error6fail			;yes, fail test
	test cl, 00000010b		;5Ah-5Bh or 7Ah-7Bh?
	jz beginning06			;No. check next
	test cl, 00000001b		;5Bh or 7Bh?
	jnz error6fail			;yes, fail test
	jmp beginning06			;No. check next
	
error0fail:					;password too long or too short

	xor al, al					;clear al
	or al, 00000001b			;turn on bit 0. Signifies password length incorrect
	jmp error01					;jump to next error check
	
error1fail:
	or al, 00000010b			;turn on bit 1. Signifies incorrect first character
	jmp error02
	
error2fail:
	or al, 00000100b			;turn on bit 2. Signifies no lowercase alphas
	jmp error03
	
error3fail:
	or al, 00001000b			;turn on bit 3. Siginifies no uppercase alphas
	jmp error04

error4fail:
	or al, 00010000b			;turn on bit 4. Signifies no special characters
	jmp error05
	
error5fail:
	or al, 00100000b			;turn on bit 5. Signifies no numerics
	jmp error06
	
error6fail:
	or al, 01000000b			;turn on bit 6. Signifies invalid characters
	
exit:

	add esp, 4		;get local variable off the stack
	pop esi
	pop edi
	pop ecx			;restore registers
	pop ebx
	pop ebp			;restore base pointer
	ret				
getpassword endp

COMMENT!
/***********************************************************************************
 * Method Name: getNum
 * Method Purpose: Get a numeric value from the user. Validate it to be a valid 
 *				   number.
 *
 *
 * Date created: 11/12/2012
 * Date last modified: 11/13/2012
 *
 * Parameters:	
 *		@param lpStringToHoldNumericChars:dword
 *      @param dLength:dword
 *
 ***********************************************************************************
 !
 getNum PROC
 
	push ebp		;preserve base pointer
	mov ebp, esp	;set the stack frame
	push eax
	push ebx		;preserve registers
	push edi
	push esi
	
maxNumLength equ [ebp+12]		;2nd parameter. Max length of the number
	mov ebx, [ebp+8]			;ebx --> address of the string to hold
	
asterisk equ 02Ah	
backspace equ 08h	;labels for ascii key codes
enterkey equ 0Dh
space equ 020h
	
	xor esi, esi		;esi  = character counter, starting at 0
	xor edi, edi		;counts non-zero numbers
	
getInput:	
	call getchar		;get character for the password
	cmp al, enterkey	;check for enter key
	je done
	cmp al, backspace	;check for backspace pressed
	je backspacePressed
	cmp esi, maxNumLength	;if password has reached length limit
	je getInput			;go back to beginning
	
	test al, 10000000b	;check for bit 7 on
	jnz getInput		;not numeric or + -
	test al, 01000000b	;check for bit 6 on (40h-7Fh)
	jnz getInput		;not numeric or + -
	test al, 00100000b	;check for bit 5 off (20h-3Fh)
	jz getInput			;less than 20h, greater than 09h, not numeric or + -
	test al, 11110000b	;00h-09h?
	jz getInput			;Yes. invalid
	test al, 00010000b	;20h-2Ah?
	jz bit4off			;Yes. check for + or -
	
;30h-3Ah
	test al, 00001000b	;38h-3Fh?
	jnz bit3on			;yes, check
	test al, 00001111b	;30h?
	jz zero				;yes, validate
	inc edi				;inc count of non-zero numbers
	jmp validchar		;31h-37h. valid
	
zero:
	cmp edi, 0			;non-zero numbers in output?
	je getInput			;no. cannot enter leading zero
	jmp validchar
	
bit3on:
	test al, 00000100b	;3Ch-3Fh?
	jnz getInput		;Yes. invalid
	test al, 00000010b	;3Ah-3Bh?
	jnz getInput		;Yes. invalid
	inc edi				;inc count of non-zero numbers
	jmp validchar		;38h-39h. valid
	
bit4off:
	cmp esi, 0			;check for index of 0.
	jne getInput		;if not 0, cannot enter + or -
	test al, 00001000b	;check bit 3
	jz getInput			;bit 3 off, not 02Bh or 02Dh (+ or -)
	test al, 00001111b	;check for parity. eliminates 029h, 02Ah, 02Ch, 02Fh
	jp getInput			;found one of 029h, 02Ah, 02Ch, 02Fh
	test al, 00000001b	;check for last bit off. eliminates 02Eh
	jz getInput
	
validchar:
	
putc al					;character validated, print and move into string to hold
	mov [ebx+esi], al
	inc esi				;count 1 character
	jmp getInput		;get more characters after asterisk displayed
	
backspacePressed:
	cmp esi, 0			;check to see if character count = 0
	je getInput
	dec esi				;-1 from character count	
putc backspace			;move back one space
putc space				;overwrite character with a space
putc backspace			;move cursor back after overwrite
	cmp edi, 0			;check for no non-zero numbers
	je getInput			;if none, go back to input
	dec edi				;if edi > 0, decrement
	jmp getInput
	
done:					;enter key pressed. finished getting characters
	xor al, al
	mov [ebx+esi], al 	;null-terminate the string
	
	pop esi
	pop edi
	pop ebx
	pop ebx				;restore registers
	pop ebp				;restore base pointer
	
	ret 
 getNum endp


;COMMENT !
;/***********************************************************************************
; * Method Name: stringLength
; * Method Purpose: Count the length of a string passed as a parameter
; *
; *
; * Date created: 10/23/2012
; * Date last modified: 10/28/2012
; *
; * Parameters:	
; *		@param lpStringToCount:dword
; * Return:		
; *		@return eax 
; *
; ***********************************************************************************
; !
stringLength PROC
 
	push ebp				;preserve base pointer
	mov ebp, esp			;set the stack frame
	push ebx				;preserve the value of ebx
	push ecx
	push esi				;preserve value of esi	
	 
	xor eax, eax				;prime eax. will hold the length of the string	 
	xor esi, esi
	mov ebx, [ebp+8]	;ebx --> address of strAddress
	
count:
	
	mov ecx, [ebx+esi]	;ecx gets value of strAddress byte by byte
	cmp cl, 0			;look for end of string
	je lengthDone	;finished if character 0
	inc esi			;increment to find next index in string
	inc eax			;increment to track the length
	jne count		;keep counting if character not 0

lengthDone:
	pop esi
	pop ecx
	pop ebx			;restore registers used
	pop ebp
	
	ret
stringLength endp

END
