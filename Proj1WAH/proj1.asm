;************************************************************************************
; Program Name:	proj1.asm
; Programmer:	Austin Horne
; Class:		CSCI 2160
; Lab:			Proj1
; Date:			September 27, 2012
; Purpose:		To evaluate a set of given mathematical equations expressed in Java
;				notation. The variables are defined in the data segment.
;					bVal 3 = bVal1 + bVal2
;					sVal3 [0] = sVal1[0] + sVal2[0]
;					sVal3 [1] = sVal1[1] + sVal2[2]
;					sVal3 [2] = sVal1[2] + sVal2[2]
;					iNum3 = iNum1 + iNum2
;					sVal4 = (bVal2 + sVal1[1] + iNum2 ) 
;					iNum4=  bVal1 + sVal3[2] + iNum1 
;
;************************************************************************************

		.486
		.model flat
		ExitProcess PROTO NEAR32 stdcall, dwExitCode:DWORD
		
		.stack 100h		
		
		;beginning of the data segment
		.data
		
			bVal1	byte 	-1			;byte holding decimal -1, referenced by bVal1
			bVal2	byte	19			;byte holding decimal 19, referenced by bVal2
			bVal3	byte	?			;unassigned byte referenced by bVal3
			sVal1	word	27,39, -2	;an array of words referenced by sVal1
			sVal2	word	37, 25, 19	;an array of words referenced by sVal2
			sVal3	word	3 dup(?)	;an array of words referenced by sVal3
			sVal4	word	?			;unassigned word referenced by sVal4
			iNum1	dword	-1			;decimal -1 as a dword, referenced by iNum1
			iNum2	dword  	43			;decimal 43 as a dword, referenced by iNum2
			iNum3	dword  	?			;unassigned dword, referenced by iNum3
			iNum4	dword 	?			;unassigned dword, referenced by iNum4
		;end of data segment
		
		;beginning of code segment
		.code
		_start:
		
			;Problem a)
			;bVal1 reference is moved into the AL register so that addition of bVal1
			;and bVal2 can be performed. Result is moved to bVal3.
			mov al, bVal1	
			add al, bVal2
			mov bVal3, al
			
			;Problem b-1
			;sVal1 is moved into the 2 byte register AX so that addition of sVal1 and
			;sVal2 can be performed. Result is stored in sVal3.
			mov ax, sVal1	
			add ax, sVal2
			mov sVal3, ax
			
			;Problem b-2
			;The second value in the sVal1 array, referenced by sVal1 with offset of 
			;2, is moved into the 2 byte register AX so that addition of the second
			;value in array sVal1 and the third value in array sVal2 can be 
			;performed. Result of the addition is stored in the second position in
			;the sVal3 array at offset 2.
			mov ax, sVal1[2]	
			add ax, sVal2[4]
			mov sVal3[2], ax
			
			;Problem b-3
			;The third value in the sVal1 array, referenced by sVal1 with offset of 
			;4, is moved into the 2 byte register AX so that addition of the third
			;value in array sVal1 and the third value in array sVal2 can be 
			;performed. Result of the addition is stored in the third position in 
			;the sVal3 array at offset 4.
			mov ax, sVal1[4]	
			add ax, sVal2[4]
			mov sVal3[4], ax
			
			;Problem c
			;iNum2 reference is moved into the 4 byte eax register so that addition 
			;of iNum2 and iNum1 can be performed. Result of the addition is stored in
			;iNum3.
			mov eax, iNum2	
			add eax, iNum1
			mov iNum3, eax
			
			;Problem d
			;Second value in the sVal1 array is sign extended and moved into the 4 
			;byte register ebx so that type matches the dword iNum2 and addition of
			;the two can be performed. bVal2 is then sign extended and moved into
			;ebx for addition with the previous result. Final result is moved into
			;the 2 byte register bx using a word pointer and, finally, the value
			;in bx is moved to our destination variable, sVal4.
			movsx ebx, sVal1[2]
			add iNum2, ebx
			movsx ebx, bVal2
			add iNum2, ebx
			mov bx, word ptr iNum2
			mov sVal4, bx
			
			;Problem e
			;The dword value iNum1 is moved into the eax register for addition with
			;bVal1 which is moved and sign extended into the ebx register so that 
			;its type will match the type of iNum1. The ebx register is then added
			;into the eax register. The third value in the array referenced by sVal3
			;is then moved and signed extended into the ebx register for addition 
			;with the value in eax. Result of the addition is stored in iNum4.
			mov eax, iNum1			
			movsx ebx, bVal1
			add eax, ebx
			movsx ebx, sVal3[4]
			add eax, ebx
			mov iNum4, eax
			
			;end of code segment
		INVOKE  ExitProcess,0		
		PUBLIC  _start
		
		END	;end of proj1.asm

		

