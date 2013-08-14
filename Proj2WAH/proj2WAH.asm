;************************************************************************************
; Program Name:	proj2WAH.asm
; Programmer:	Austin Horne
; Class:		CSCI 2160
; Lab:			Proj2
; Date:			October 13, 2012
; Purpose:		Use methods to accept input from the keyboard, convert that input 
;				into numeric values, and calculate the sum, difference, product, 
;				quotient, and remainder. Then use int to ascii conversion method to
;				print the results of each calculation. Conditional and unconditional
;				jumps are used to determine whether input was valid and whether 
;				an overflow occurred. Compare and jump equal are used to determine
;				whether the user hit only the enter key to end the program.
;
;************************************************************************************

		.486
		.model flat
		ExitProcess PROTO NEAR32 stdcall, dwExitCode:DWORD
		putstring PROTO stdcall, lpStringTOPrint:dword
		getstring PROTO stdcall, lpStringToHoldCharacters:dword, dLength:dword
		ascint32  PROTO  stdcall, lpStringToConvert:dword
		intasc32 PROTO stdcall, lpStringToHoldASCII:dword, dVal:dword
		
		.stack 100h
		
		.data
		
			iFirstNum dword ?	;holds the first number input from the keyboard
			iSecondNum dword ?	;holds the second number input from the keyboard
			iSum dword ?		;holds the sum of the two numbers
			iDifference dword ? ;holds the difference of the two
			iProduct dword ?	;holds the product of the two
			iQuotient dword ?	;holds the quotient of the two
			iRemainder dword ?	;holds the remainder of the two
			
			strNameString byte 10, 13, "My name is Austin Horne", 0
			strFirstNum byte 10, 13, "Please enter your first number: ", 0
			strSecondNum byte 10, 13, "Please enter your second number: ", 0
			strSum byte 10, 13, "The sum is: ", 0
			strDifference byte 10, 13, "The difference is: ", 0
			strProduct byte 10, 13, "The product is: ", 0
			strQuotient byte 10, 13, "The quotient is: ", 0
			strRemainder byte 10, 13, "The remainder is: ", 0
			strInvalid byte 10, 13, "INVALID NUMERIC STRING. RE-ENTER VALUE.", 0
			strOverflow byte 10, 13, "OVERFLOW OCCURRED. RE-ENTER VALUE.", 0
			strProductOverflow byte 10, 13, "OVERFLOW OCCURRED WHEN MULTIPLYING", 0
			strAdditionOverflow byte 10, 13, "OVERFLOW OCCURRED WHEN ADDING", 0
			strSubtractOverflow byte 10, 13, "OVERFLOW OCCURRED WHEN SUBTRACTING", 0
			
			strNewLine byte 10, 13, 0 	;used to add a blank line
			strInput byte 21 dup(?)		;used to hold input from the keyboard
			strOutput byte 21 dup(?), 0	;used to send output to the screen
			
		.code
		
		;If a non-numerical character is entered, this label will
		;print the string that notifies the user and ask for input
		;until valid input is received or program is terminated
		_firstInvalid:	
		INVOKE putstring, ADDR strInvalid
		INVOKE putstring, ADDR strFirstNum
		INVOKE getstring, ADDR strInput, 20
		INVOKE ascint32, ADDR strInput
		jc _firstInvalid	;Loop back to label if input is still invalid
		jmp _returnToFirst	;If input is valid and cf = 0, jump back to first input
							;to check for overflow occurrence.
		
		;If an overflow occurs, this label will print the string that notifies the 
		;user and ask for input until valid input is received or program is 
		;terminated.
		_firstOverflow:
		INVOKE putstring, ADDR strOverflow
		INVOKE putstring, ADDR strFirstNum
		INVOKE getstring, ADDR strInput, 20
		INVOKE ascint32, ADDR strInput
		jo _firstOverFlow	;Loop back to label if input still causes overflow
		jmp _setFirst		;If of = 0, input is valid, jump to label. Following
							;instruction moves eax into iFirstNum
					
		;If a non-numerical character is entered, this label will
		;print the string that notifies the user and ask for input
		;until valid input is received or program is terminated
		_secondInvalid:
		INVOKE putstring, ADDR strInvalid
		INVOKE putstring, ADDR strSecondNum
		INVOKE getstring, ADDR strInput, 20
		INVOKE ascint32, ADDR strInput
		jc _secondInvalid	;Loop back to label if input is still invalid
		jmp _returnToSecond	;If input is valid and cf = 0, jump back to second input
							;to check for overflow occurrence.
		
		;If an overflow occurs, this label will print the string that notifies the 
		;user and ask for input until valid input is received or program is 
		;terminated.
		_secondOverflow:
		INVOKE putstring, ADDR strOverflow
		INVOKE putstring, ADDR strSecondNum
		INVOKE getstring, ADDR strInput, 20
		INVOKE ascint32, ADDR strInput
		jo _secondOverFlow	;Loop back to label if input still causes overflow
		jmp _setSecond		;If of = 0, input is valid, jump to label. Following
							;instruction moves eax into iSecondNum
		
		;If product causes overflow, overflow message is printed in place of result
		;Then jumps to following calculation, division.
		_productOverflow:
		INVOKE putstring, ADDR strProductOverflow
		jmp _division
		
		;If addition causes overflow, overflow message is printed in place of result
		;Then jumps to following calculation, subtraction.
		_addOverflow:
		INVOKE putstring, ADDR strAdditionOverflow
		jmp _subtraction
		
		;If subtraction causes overflow, overflow message is printed in place of 
		;result. Then jumps to following calculation, multiplication.
		_subtractOverflow:
		INVOKE putstring, ADDR strSubtractOverflow
		jmp _multiplication		
		
		;start of code execution
		_start:
		INVOKE putstring, ADDR strNameString	;Name of programmer printed
		_beginning:								;Program jumps to this label after
												;each run
		INVOKE putstring, ADDR strNewLine		;New line for spacing
		INVOKE putstring, ADDR strFirstNum		;Prompt user for first number
		INVOKE getstring, ADDR strInput, 20		;Get input, max 20 characters
		
		mov bl, 0			
		cmp bl, strInput	;checks for only enter key hit (null character)
		je _terminate		;skips to terminate label at end of program if equal
		INVOKE ascint32, ADDR strInput	;try to convert input string to int
		jc _firstInvalid				;jump to this label if cf = 1 (bad input)
		_returnToFirst:					;return label from _firstInvalid
		jo _firstOverFlow				;jump to this label if of = 1 (overflow)
		_setFirst:						;return label from _firstOverFlow
		mov iFirstNum, eax				;when input is valid, placed in iFirstNum
		
		INVOKE putstring, ADDR strSecondNum		;Prompt user for second number
		INVOKE getstring, ADDR strInput, 20		;Get input, max 20 characters
		mov bl, 0
		cmp bl, strInput	;checks for only enter key hit (null character)
		je _terminate		;skips to terminate label at end of program if equal
		INVOKE ascint32, ADDR strInput	;try to convert input string to int
		jc _secondInvalid				;jump to this label if cf = 1 (bad input)
		_returnToSecond:				;return label from _secondInvalid
		jo _secondOverFlow				;jump to this label if of = 1 (overflow)
		_setSecond:						;return label from _secondOverFlow		
		mov iSecondNum, eax				;when input is valid, placed in iSecondNum
		
		add eax, iFirstNum	;eax still contains second number input, add with 1st
		jo _addOverflow		;if overflow occurs, message will be printed 
		mov iSum, eax		;else, result moved to iSum and iSum printed
		INVOKE intasc32, ADDR strOutput, iSum
		INVOKE putstring, ADDR strSum
		INVOKE putstring, ADDR strOutput
		
		_subtraction:
		mov eax, iFirstNum		
		sub eax, iSecondNum		;subtract second number from first
		jo _subtractOverflow
		mov iDifference, eax
		INVOKE intasc32, ADDR strOutput, iDifference
		INVOKE putstring, ADDR strDifference
		INVOKE putstring, ADDR strOutput	;convert and output the difference
		
		_multiplication:
		mov eax, iFirstNum	
		imul iSecondNum			;multiply first and second numbers
		jo _productOverflow	
		mov iProduct, eax
		INVOKE intasc32, ADDR strOutput, iProduct
		INVOKE putstring, ADDR strProduct
		INVOKE putstring, ADDR strOutput	;convert and output the product
		
		_division:
		mov eax, iFirstNum
		cdq
		iDiv iSecondNum			;divide first by second
		mov iQuotient, eax		
		INVOKE intasc32, ADDR strOutput, iQuotient
		INVOKE putstring, ADDR strQuotient
		INVOKE putstring, ADDR strOutput		;convert and output the quotient
		
		mov iRemainder, edx		
		INVOKE intasc32, ADDR strOutput, iRemainder
		INVOKE putstring, ADDR strRemainder
		INVOKE putstring, ADDR strOutput	;convert and output the remainder
		
		jmp _beginning		;returns to ask for first number
		
		_terminate:			;used to skip to end only when the enter key is hit
		
		INVOKE ExitProcess, 0
		PUBLIC _start
		
		END