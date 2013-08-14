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
extern  getchar:near32, putchar:near32, getpassword:near32, stringLength:near32,
		getNum:near32
	
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
************************************************************************************
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
