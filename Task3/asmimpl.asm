sectoin .text

	extern malloc
	extern free

	global biFromInt
	global biFromString
	global biToString
	global biDelete
	global biSign
	global biAdd
	global biSub
	global biMul
	global biCmp

	struc	BInt
sign:	resq	1
start:	resq	1
size:	resq	1
limit:	resq	1
	endstruc

	;; FORBIDEN AS PARAMETERS FOR MACRO:
	;; RAX, RDI, R13, R14, R15


	;; Initialises a BigInt with initial inner
	;; vector size %2 and stores in %1 
	;; TAKES:
	;;	%1 - address of the bInt
	;;	%2 - initial vector size
	;; USES:
	;;	RAX - address of allocated memory (bInt and vector)
	;;	RDI - size of allocated memory
	%macro bInit	2
		push	rdi
		push	rax
		mov	rdi, BInt_size
		call 	malloc
		mov	%1, rax
		mov	qword [%1 + sign], 0
		mov	qword [%1 + size], 0
		mov	qword [%1 + limit], %2
		mov	rdi, %2
		shl	rdi, 2
		call	malloc
		mov	[%1 + start], rax
		shr	rdi, 2
		;;TODO 0 for cells	
		pop	rax
		pop	rdi
	%endmacro
	
	;; Add a new rank in BigInt inner vector
	;; TAKES:
	;;	%1 - address of the bInt
	;;	%2 - pushed value
	;; USES:
	;;	R8 - size
	%macro 	bPush	2
		push 	r13
		push	r14
		mov	r13, [%1 + size]
		cmp	r13, [%1 + limit]
		jge	.after_resize
		bEnl	%1
.after_resize	mov	r14, [%1 + start]
		lea	r14, [r14 + r13 * 4]
		mov	[r14], %2
		inc	r13
		mov	[%1 + size], r13
		pop	r14
		pop	r13
	%endmacro


	;; Enlarges inner vector of bInt in 2 times
	;; TAKES
	;;	%1 - address of bInt
	%macro	bEnl 	1
		push	r13
		push	r14
		push	r15
		push	rdi
		push	rax
		mov	r13, [%1 + limit]
		shl	r13, 1
		bInit	rax, r13
		mov	r13, [%1 + size]
		mov	[rax + size], r13
		mov	r13, [%1 + start]
		mov	r14, [rax + start]
		mov	r15, [%1 + size]
.enl_loop	mov	rdi, [r13]
		mov	[r14], rdi
		dec	r15
		jnz	.enl_loop
		pop	rax
		pop	rdi
		pop	r15
		pop	r14
		pop	r13
	%endmacro
	
	%macro	bPop 2
		push	r13
		push	r14
		mov	r13, [%1 + size]
		dec	r13
		mov	r14, [%1 + start]
		lea	r14, [r14 + r13 * 4]
		mov	%2, [r14]
		mov	[%1 + size], r13
		pop	r14
		pop	r13
	%endmacro

	

        ;; casn (Cells ASSigN)                                                                                                                                    
        ;; Macro for assignment the %3 value for all cells in matrix                                                                                              
        ;; Takes:                                                                                                                                                 
        ;;      %1 - address of the first cell in cells array                                                                                                     
        ;;      %2 - number of cells                                                                                                                              
        ;;      %3 - assigned value                                                                                                                               
        ;; Uses:                                                                                                                                                  
        ;;      rdi, rcx, rax - rep requirements                                                                                                                  
        ;; Returns:                                                                                                                                               
        ;;      %1 - array of cells, valueted by %3                                                                                                               
	%macro casn 3
		mov rdi, %1
		mov rcx, %2
		mov eax, %3
		cld
		rep stosd
	%endmacro
	

	
