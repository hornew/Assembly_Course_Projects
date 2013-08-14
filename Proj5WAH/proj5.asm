;************************************************************************************
; Program Name:  proj5.asm
; Programmer:    Austin Horne
; Class:         CSCI 2160
; Date:          December 2, 2012
; Purpose:
;    Using linked lists. Display the use of linkedlist.asm
;
;************************************************************************************  
	.486
	.model flat
	.stack 100h
	include macros.asm	
	.data

node	struct
	key		dword ?
	info	byte	24 dup(?)
	next	dword ?
node	ends


pred	 	dword	?
succ		dword	?
startnode	dword	node3
avail		dword   node6
num 		dword 	?
nodestructure label byte
node1	node	<37,"John Henry              ", node2>
node2	node	<55,"Alex Smith              ", -1  >
node3	node	<15,"Betty Davis             ", node5  >
node4	node	<26,"Freddy Washington       ", node1  >
node5   node	<18,"Wilson Wallis           ", node4  >
node6	node	<,,node7>
node7	node	<,,node8>
node8	node	<,,node9>
node9	node	<,,node10>
node10	node	<,,-1>
node11 	node	<27,"Fred                    ", -1>
crlf	byte 10,13,0
cout 	byte	10 dup(?),0
strTraverse byte	"Key",9,"Address",9,9,"Info",0
strListnodes byte	"Listnodes procedure: printing addresses",0
EnterKey 	byte	"Enter key to search for ",0
keynotfound byte	"Key was not found in the list: ",0
addressIs	byte	"Address of the node is:",0
strPred		byte 	"Predecessor: ",0
strSucc		byte	"Successor: ",0
strRemove	byte	"Remove first cell in list: ",0
strAvail	byte	"Traversing available nodes: ",0
strStart	byte	"Traversing list: ",0
strInsert	byte	"Insert cell",0
strInit		byte	"Initializing:",0
	.code
_start:
	
	;INVOKE getcell, addr avail
	
	;test the traverse method
	newline
	INVOKE putstring, addr strTraverse
	INVOKE traverse, startnode
	newline
	newline
	
	;test the listnodes method
	INVOKE putstring, addr strListnodes
	INVOKE listnodes, startnode
	newline
	newline
	
	;test the findkey method
	invoke putstring, addr enterkey
	invoke getstring, addr cout, 11
	invoke ascint32, addr cout

	mov num, eax
	INVOKE findkey, startnode, num, addr pred, addr succ
	
	;print error if findkey returns -1; print address if not -1
	.IF(eax == -1)
		newline
		newline
		invoke putstring, addr keynotfound
	.else
		newline
		newline
		invoke putstring, addr addressIs
	.endif
	
	;convert value returned by findkey to string
	INVOKE intasc32, addr cout, eax
	;print the value
	INVOKE putstring, addr cout
	
	;PRINT PREDECESSOR
	newline
	newline
	invoke intasc32, addr cout, pred
	invoke putstring, addr strPred
	invoke putstring, addr cout
	
	;PRINT SUCCESSOR
	newline
	newline
	invoke intasc32, addr cout, succ
	invoke putstring, addr strSucc
	invoke putstring, addr cout
	
	;REMOVE A CELL
	newline 
	newline
	invoke putstring, addr strRemove
	newline
	invoke removecell, addr startnode, addr avail, startnode, pred, succ
	
	;traverse avail
	newline
	newline
	invoke putstring, addr strAvail
	newline
	invoke traverse, avail
	
	;traverse startnode
	newline
	newline
	invoke putstring, addr strStart
	newline
	invoke traverse, startnode
	
	;insert cell
	newline
	newline
	invoke putstring, addr strInsert
	newline
	mov ecx, offset node11
	mov num, ecx
	invoke insertcell, addr startnode, num, pred, succ
	
	;traverse startnode
	newline
	newline
	invoke putstring, addr strStart
	newline
	invoke traverse, startnode
	
	;init
	newline
	newline
	invoke putstring, addr strInit
	newline
	invoke init, addr startnode, addr avail, addr pred, addr succ, num, startnode
	
	;traverse array of nodes
	invoke traverse, avail
	
	INVOKE ExitProcess,0
	PUBLIC _start
	
	END
	