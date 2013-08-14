;************************************************************************************
; Program Name:  linkedlist.asm
; Programmer:    Austin Horne
; Class:         CSCI 2160
; Date:          December 2, 2012
; Purpose:
;    Using linked lists. Allow inserting, removing, intializing, traversing, and
;	 listing of addresses of nodes in a linked list. Links are maintained 
;	 appropriately in each method.
;
;************************************************************************************
	.486
	.model flat
	include macros.asm
	.stack 100h
	
node	struct
	key		dword ?
	info	byte	24 dup(?)
	next	dword ?
node	ends

	.data
	
	
	.code

COMMENT !
/***********************************************************************************
 * Method Name: init
 * Method Purpose: Initialize all of the nodes in a list and add them to a list of
 *					available nodes.
 *
 * Date created: 11/22/2012
 * Date last modified: 11/29/2012
 *
 * Parameters:	@param lpStartNode:dword	[ebp+8]
 *				@param lpAvail:dword		[ebp+12]
 *				@param lpPred:dword			[ebp+16]
 *				@param lpSucc:dword			[ebp+20]
 *				@param num:dword			[ebp+24]
 *				@param startnode:dword		[ebp+28]
 ***********************************************************************************
 !
 init proc stdcall uses ebx ecx edi esi, lpStartNode:dword, lpAvail:dword, 
							 lpPred:dword, lpSucc:dword, num:dword, startnode:dword
 	
	ASSUME ebx:ptr node
	
	mov edi, lpStartNode
	mov esi, lpAvail
	mov esi, [esi]	;get value of avail into esi
	
	mov ebx, [edi]	;get startnode into ebx
	
	.WHILE(ebx != -1) ;get last node
		mov ecx, ebx	;save current node
		mov ebx, [ebx].next	;point to next node; last node at end of loop
	.ENDW
	
	mov ebx, ecx	;get last node into ebx
	mov [ebx].next, esi	;move beginning of avail to next node of last node
	mov esi, lpAvail
	mov ebx, [edi]
	mov [esi], ebx		;move start node to beginning of avail
	mov esi, -1
	mov [edi], esi		;put -1 into start node
	
	ret 24		;6 dword params
 init endp
 
 COMMENT !
 /***********************************************************************************
 * Method Name: listnodes
 * Method Purpose:  List all of the addresses of nodes in a given list of nodes.
 *
 * Date created: 11/24/2012
 * Date last modified: 11/29/2012
 *
 * Parameters:	
 *		@param lpStartingAddress:dword	[ebp+8]
 ***********************************************************************************
 !
 
 listnodes proc stdcall uses ebx ecx esi, lpStartingAddress:dword
	LOCAL _strOut[24]:byte		;local storage for string printing
	
	xor ebx, ebx
	ASSUME ebx:ptr node			;ebx --> a node structure
	
	mov ebx, lpStartingAddress	;starting address of node structure
	
	.WHILE ( ebx != -1 )	;traverse until -1 found in next field
		newline		;macro
		
		INVOKE intasc32, addr _strOut, ebx	;convert address to string for printing
		INVOKE putstring, addr _strOut
		
		mov ebx, [ebx].next		;ebx --> next address
	.ENDW
		
	ret 4	;one dword parameter
 listnodes endp
 
 COMMENT !
/***********************************************************************************
 * Method Name: getcell
 * Method Purpose: Return in eax the value of avail. Set avail to the value of 
 *				   successor of avail.
 *
 * Date created: 11/24/2012
 * Date last modified: 12/1/2012
 *
 * Parameters:	
 *		@param lpAvail:dword	[ebp+8]
 ***********************************************************************************
 !
 
 getcell proc stdcall uses ebx edi, lpAvail:dword
	
	ASSUME ebx:ptr node		;ebx --> a node structure
	mov edi, lpAvail		;ebx --> address of avail
	mov ebx, [edi]			;ebx --> first address contained in avail
	
	.IF ebx == -1
		mov eax, -1		;return -1 if value of avail is -1
	.ELSE
		mov eax, ebx	;return value of avail
		mov ebx, [ebx].next		;move value of lpAvail.next into ebx
		mov edi, lpAvail
		mov [edi], ebx		;set value of lpAvail to lpAvail.next
		
	.ENDIF
		
	ret	4	;1 dword param
 getcell endp
 
 
 COMMENT !
/***********************************************************************************
 * Method Name: traverse
 * Method Purpose: Step through a linked list and display the info and key values
 *				   of each node.
 *
 * Date created: 11/24/2012
 * Date last modified: 11/29/2012
 *
 * Parameters:	
 *		@param startNode:dword	
 ***********************************************************************************
 !
 traverse PROC stdcall uses ebx esi ecx, startNode:dword	
	LOCAL _strOut[24]:byte		;local storage for string printing

	xor ebx, ebx	
	
	ASSUME ebx:ptr node		;ebx --> a node structure	
	mov ebx, startNode		;ebx -> starting address of first node
	
	.WHILE ( ebx != -1 )	;traverse until -1 found in next field
		newline		;macro
		mov ecx, [ebx].key	;get key value of current node
		INVOKE intasc32, addr _strOut, ecx
		INVOKE putstring, addr _strOut
		
		tab 	;macro
		
		INVOKE intasc32, addr _strOut, ebx	;convert address to string for printing
		INVOKE putstring, addr _strOut	

		tab
		tab
		
		xor esi, esi				;clear esi
		mov ecx, sizeof node.info	;length of info
		.WHILE ( esi < ecx )		;print until length of info reached
			putc [ebx].info[esi]
			inc esi					;track index of info field
		.ENDW
		
		mov ebx, [ebx].next		;ebx --> next address
	.ENDW
	
	ret 4	;one dword param
 traverse endp
 
 COMMENT !
/***********************************************************************************
 * Method Name: insertcell
 * Method Purpose: Insert a given node into a linked list
 *
 * Date created: 11/24/2012
 * Date last modified: 11/29/2012
 *
 * Parameters:	
 *		@param lpStartNode:dword
 *		@param newcell:dword
 *		@param pred:dword
 *		@param succ:dword
 ***********************************************************************************
 !
 insertcell proc stdcall uses ebx ecx edi edx, lpStartNode:dword, newcell:dword,
											pred:dword, succ:dword
	ASSUME ebx:ptr node
	
	mov edx, lpStartNode	;edx --> lpStartNode
	mov edi, [edx]			;edi --> value of startnode (address of 1st node in list)		
	
	mov ebx, newcell			
	mov edx, [ebx].key		;edx --> key to search for
	
	invoke findKey, edi, edx, addr pred, addr succ
	
	mov edx, lpStartNode	;edx --> lpStartNode
	mov edi, [edx]			;edi --> value of startnode (address of 1st node in list)		
	
	mov ebx, newcell			
	mov edx, [ebx].key		;edx --> key to search for
	
	.IF(eax == -1)	;Prevent duplicate keys from being inserted
	;if cell is before startnode
		.IF(pred == -1)
			mov [ebx].next, edi		;set newcell next field to startnode
			mov [edi], ebx			;set startnode to newcell
			
		.ELSEIF(succ == -1)
		
			mov ebx, edi
			.WHILE(ebx != -1)	;find last node. ecx will contain last node
				mov ecx, ebx		;save the value of current node in list
				mov ebx, [ebx].next	;find last node in list
			.ENDW	
		
			mov ebx, ecx	;get last node into ebx 
			mov ecx, newcell
			mov [ebx].next, ecx
			mov ebx, ecx	;get new last node into ebx
			mov ecx, -1
			mov [ebx].next, ecx	;value of last node.next will be -1
			
		.ELSE
			mov ebx, pred	;pred points to an address of a node
			mov ecx, newcell
			mov [ebx].next, ecx
			mov ebx, ecx	;put newcell in ebx which is pointer to node
			mov ecx, succ
			mov [ebx].next, ecx	;link newcell to end of list
		.ENDIF
	.ENDIF
	
	ret 8	;2 dword params
 insertcell endp
 
 
 COMMENT !
/***********************************************************************************
 * Method Name: removecell
 * Method Purpose: Remove a cell at a specified position from a given list and
 *				   append it to the beginning of an available list
 *
 * Date created: 11/24/2012
 * Date last modified: 11/29/2012
 *
 * Parameters:	
 *		@param lpStartNode:dword
 *		@param lpAvail:dword
 *		@param cell:dword
 *		@param pred:dword
 *		@param succ:dword
 *
 * Returns:
 *		eax
 ***********************************************************************************
 !
 removecell proc stdcall uses ebx ecx edi edx esi, lpStartNode:dword, lpAvail:dword,
									 cell:dword, pred:dword, succ:dword	
	ASSUME ebx:ptr node		;ebx --> a node struct
	
	mov edx, lpStartNode	;edx --> lpStartNode
	mov edi, [edx]			;edi --> value of startnode (address of 1st node in list)		
	
	mov ebx, cell			
	mov edx, [ebx].key		;edx --> key to search for
	
	invoke findKey, edi, edx, addr pred, addr succ
	
	.IF(eax != -1)	;if key exists in the list, eax will not be -1
		mov edi, pred			
		.IF(edi == -1)		;if removing first node
			mov esi, lpStartNode ;set esi = ADDRESS of start node
			mov ebx, [esi]		;set ebx = address of beginning node in list
			mov esi, lpAvail	;set esi = ADDRESS of avail
			mov edx, [esi]		;set edx = address of the first node in avail			
						
			mov ecx, [ebx].next	;set ecx to next node in list
			mov [ebx].next, edx	;set successor to beginning of avail
			mov [esi], ebx		;set beginning of avail to node
			
			mov esi, lpStartNode	
			mov [esi], ecx		;set beginning of list to next node
		.ENDIF
		
		mov edi, succ
		.IF(edi == -1)	;If removing last node
			mov esi, lpStartNode
			mov ebx, [esi]	;ebx --> beginning of list
			mov edx, [ebx].next	;edx --> next address
			.WHILE(edx != -1)
				mov ecx, ebx	;save current node
				mov ebx, [ebx].next
				mov edx, [ebx].next	;edx --> next node				
			.ENDW
			mov esi, lpAvail
			mov esi, [esi]	;esi --> beginning address of avail
			mov [ebx].next, esi ;next field of node now points to beginning of avail
			mov [esi], ebx		;node now first in avail
			mov ebx, ecx		;set ebx = next to last node
			mov esi, -1
			mov [ebx].next, esi
		.ENDIF
	.ENDIF
	
	ret 20	;5 dword params
 removecell endp
 
 COMMENT !
/***********************************************************************************
 * Method Name: findKey
 * Method Purpose: Search a list for a key. Return the addres of the node that 
 *				   contains the key. Set the pred and succ to the corresponding 
 *				   addresses. Returns -1 if the value is not in the list. If list is
 *				   empty, return -1 and set pred and succ to -1.
 *
 * Date created: 11/24/2012
 * Date last modified: 11/29/2012
 *
 * Parameters:	
 *		@param startNode:dword	
 *		@param value:dword
 *		@param lpPred:dword
 *		@param lpSucc:dword
 * Returns:
 *		eax
 ***********************************************************************************
 !
 findkey proc stdcall uses ebx ecx edi edx esi, startNode:dword, value:dword,  
									lpPred:dword, lpSucc:dword
	xor ebx, ebx
	xor eax, eax
	ASSUME ebx:ptr node	
	mov ebx, startNode		;ebx --> address of start node
	mov esi, value			;esi contains key to search for
	
	.IF(ebx == -1)	;check for empty list
		mov eax, -1			;return -1
		mov edi, lpPred
		mov [edi], eax		;set pred to -1
		mov edi, lpSucc
		mov [edi], eax		;set succ to -1
	.ENDIF
	
	.IF(eax == 0 && esi < [ebx].key)	;if the value is less than startnode key
		mov eax, -1		;return -1
		mov edi, lpPred
		mov [edi], eax		;set pred to -1
		mov edi, lpSucc
		mov [edi], ebx ;set succ to address of startnode		
	.ENDIF
	
	;loop until end of list is reached
	.WHILE(ebx != -1 && eax == 0)
		mov edx, [ebx].next		;edx -> address of next cell
		
		.IF(esi == [ebx].key) ;check for parameter "value" equal to key in list
						
			.IF(ebx == startNode)	;If the key matches startnode key
				mov edi, lpPred		
				mov eax, -1			;set pred to -1
				mov [edi], eax
				mov edi, lpSucc
				mov [edi], edx	;set succ to next address
				
			.ELSEIF(edx == -1)		;if value matches last node key
				mov edi, lpPred
				mov [edi], ecx		;set pred to previous address
				mov edi, lpSucc
				mov eax, -1
				mov [edi], eax		;set succ to -1; eax contains -1
				
			.ELSE					;If value matches key in between start and last 
				mov edi, lpPred		
				mov [edi], ecx		;set pred to previous key
				mov edi, lpSucc
				mov [edi], edx		;set succ to next key; edx contains [ebx].next			
			.ENDIF						
			
			mov eax, ebx		;key found, set eax to address of current node
		
		.ENDIF
				
		mov ecx, ebx			;ecx --> current address; last node if loop ends
		mov ebx, [ebx].next		;ebx --> next address
	.ENDW
		
		mov ebx, ecx		;ebx --> address of last node
		
		;if the key to search for is less then key of last node
		.IF(esi > [ebx].key && eax == 0) 
			mov edx, -1			
			mov edi, lpPred
			mov [edi], ecx		;predecessor of this key is last node
			mov edi, lpSucc
			mov [edi], edx		;successor to this key is -1
			mov eax, -1			;return -1
		.ENDIF	

	.IF(eax == 0)	;check to see if value was in between nodes in list
		mov ebx, startNode		;ebx --> address of start node
		mov esi, value			;esi contains key to search for
		
		;loop until end of list is reached or position key should be in is found
		.WHILE(ebx != -1 && eax != -1)	
			mov edi, ebx			;save address of current node
			mov ebx, [ebx].next		;set ebx = address of next node
			mov ecx, [ebx].key		;set ecx = value of next node's key
			mov ebx, edi			;restore address of current node into ebx
			
			;if key to search for is in between keys in the list
			.IF(esi > [ebx].key && esi < ecx) 
				mov ecx, [ebx].next		;ecx --> address of next node in list
				mov edi, lpPred
				mov [edi], ebx			;predecessor set to current node
				mov edi, lpSucc
				mov [edi], ecx		;successor set to next node
				mov eax, -1			
			.ENDIF
		
			mov ecx, ebx			;ecx --> current address; last node if loop ends
			mov ebx, [ebx].next		;ebx --> next address
		.ENDW
	.ENDIF
	
	ret 16	;4 dword params
 findkey endp
 
 END
 
 
 
 
 
 