;************************************************************************************
; Program Name:	macros.asm
; Programmer:	Austin Horne
; Class:		CSCI 2160
; Purpose:		To use macros, PROTO, and extern directives.
;
;************************************************************************************
ExitProcess PROTO stdcall, dwExitCode:DWORD
putstring PROTO stdcall, lpStringTOPrint:dword
getstring PROTO stdcall, lpStringToHoldCharacters:dword, dLength:dword
ascint32  PROTO  stdcall, lpStringToConvert:dword
intasc32 PROTO stdcall, lpStringToHoldASCII:dword, dVal:dword

init PROTO stdcall, lpStartNode:dword, lpAvail:dword, lpPred:dword, lpSucc:dword, 
					num:dword, startnode:dword
getcell PROTO stdcall, lpAvail:dword
findKey PROTO stdcall, startNode:dword, value:dword, lpPred:dword, lpSucc:dword
traverse PROTO stdcall, startNode:dword
insertCell PROTO stdcall, lpStartNode:dword, newcell:dword, pred:dword, succ:dword
removeCell PROTO stdcall, lpStartNode:dword, lpAvail:dword, cell:dword, pred:dword,
						  succ:dword
listnodes PROTO stdcall, lpStartingAddress:dword
extern putchar:near32
		
COMMENT!
/************************************************************************************
 * Name: intToAscii
 * Date: 11/14/12
 * Purpose: To convert integer to ascii characters. Invokes the intasc32 method from 
			convutil201211.obj
 * Parameters:
		@param lpStringToConvert
		@param iVal
************************************************************************************
!
intToAscii macro lpStringToHold, iVal
	push ebx	;preserve
	
	lea ebx, [lpStringToHold]	;ebx ->> address of lpStringToHold
	INVOKE intasc32, ebx, iVal
	
	pop ebx		;restore
endm
COMMENT!
/************************************************************************************
 * Name: asciiToInt
 * Date: 11/9/12
 * Purpose: To convert ascii characters to integer. Invokes the ascint32 method from 
			convutil201211.obj
 * Parameters:
		@param lpStringToConvert
		@param iVal
************************************************************************************
!
asciiToInt macro lpStringToConvert, iVal
	push ebx		;preserve registers
	
	lea ebx, [lpStringToConvert]	;address of string to convert <-- ebx
	INVOKE ascint32, ebx
	mov iVal, eax
	
	pop ebx	;restore
endm
	
COMMENT!
/************************************************************************************
 * Name: getc
 * Date: 11/9/12
 * Purpose: To get a character from the keyboard. Calls the getchar method from 
			Utility201211.obj
 * Parameters:
		@param char:byte
************************************************************************************
!
getc macro char
	push eax		;preserve register
	
	call getchar
	mov char, al	;get the returned character into the parameter
	
	pop eax			;restore register	
endm

COMMENT!
/************************************************************************************
 * Name: putc
 * Date: 11/9/12
 * Purpose: To display a character on the screen. Calls the putchar method from 
			Utility201211.obj
 * Parameters:
		@param char:byte
************************************************************************************* 
!
putc macro char 
	push eax		;;preserve eax
	mov al, char	;;get the character passed into AL for the putchar procedure
	push eax		;;pass parameter to putchar
	call putchar 
	add esp, 4		;;restore stack pointer
	pop eax			;restore eax
endm

COMMENT!
/************************************************************************************
 * Name: newline
 * Date: 11/9/12
 * Purpose: Use the putc macro to display a carriage return and line feed to move 
 *			output to the next line.
************************************************************************************
!	
newline macro
	putc 0Dh		;;carriage return
	putc 0Ah		;;new line character
endm

COMMENT!
/************************************************************************************
 * Name: tab
 * Date: 11/30/12
 * Purpose: Use the putc macro to display a tab character
************************************************************************************
!
tab macro
	putc 09h
endm 