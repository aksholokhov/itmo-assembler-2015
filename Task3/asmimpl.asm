section .text

	extern malloc
	extern free

	global bInit
	global bPop
	global bPush
	global bEnl
	global biToStringAsIs	;; outs inner array of bInt "as is" (for debugging) TODO: remove from global before submitting
	global biAddMod		;; |a| + |b|, TODO: remove from global before submitting

	global biFromInt
	global biFromString
	global biToString
	global biDelete
	global biSign
	global biAdd
	global biSub
	global biMul
	global biCmp

	struc	BigInt
sign:	resq	1
start:	resq	1
vsize:	resq	1
limit:	resq	1
	endstruc



	;; Initialises a BigInt with initial inner
	;; vector size %2 and stores in %1 
	;; TAKES:
	;;	RDI - initial vector size
	;; USES:
	;;	RAX - address of allocated memory (bInt and vector)
	;;	RDI - size of allocated memory
	;; RETURNS:
	;;	RAX - new bInt
bInit:		push	r8
		push	r9
		push	rcx
		push	rsi
		mov	r8, rdi
		mov	rdi, BigInt_size
		push	r8
		call 	malloc
		pop	r8
		mov	qword [rax + sign], 0
		mov	qword [rax + vsize], 0
		mov	qword [rax + limit], r8
		mov	rdi, r8
		shl	rdi, 3
		mov	r9, rax
		push	r9
		call	malloc
		pop	r9
		mov	[r9 + start], rax
		mov	rax, r9	
		pop	rsi
		pop	rcx
		pop	r9
		pop	r8
		ret
	
	;; void bPush(BigInt a, int v)
	;; Add a new rank in BigInt inner vector
	;; TAKES:
	;;	RDI - address of the bInt
	;;	RSI - pushed value
	;; USES:
	;;	R8 - size
bPush:		push 	r8
		push	r9
		mov	r8, [rdi + vsize]
		mov	r9, [rdi + limit]
		cmp	r8, r9
		jl	.after
		call	bEnl
.after		mov	r9, [rdi + start]
		lea	r9, [r9 + r8 * 8]
		mov	[r9], rsi
		inc	r8
		mov	[rdi + vsize], r8
		pop	r9
		pop	r8
		ret

	;; void bEnl(BigInt a)
	;; Enlarges inner vector of bInt in 2 times
	;; TAKES
	;;	RDI - address of bInt
bEnl: 		push	r8
		push	r9
		push	r10
		push	rax
		push	rsi
		mov	rsi, rdi
		mov	rdi, [rsi + limit]
		shl	rdi, 4
		push	rsi
		push	rdi
		call	malloc
		pop	rdi
		pop	rsi
		shr	rdi, 3
		mov	[rsi + limit], rdi
		mov	r8, [rsi + start]
		mov	r10, [rsi + vsize]	
		mov	r9, rax
.enl_loop	mov	rdi, [r8]
		mov	[r9], rdi
		add	r8, 8
		add	r9, 8
		dec	r10
		jnz	.enl_loop
		mov	[rsi + start], rax
		mov	rdi, rsi
		pop	rsi	
		pop	rax
		pop	r10
		pop	r9
		pop	r8
		ret

		;; void bPop(BigInt a, int v)
		;; makes "pop" from the inner BigInt vector to the v
		;; TAKES:
		;;	rdi - bInt
		;;	rsi - int v
bPop 		push	r8
		push	r9
		mov	r8, [rdi + vsize]
		cmp	r8, 0
		jne	.to_pop
		mov	rsi, 0
		jmp	.to_pop_end
.to_pop		dec	r8
		mov	r9, [rdi + start]
		lea	r9, [r9 + r8 * 4]
		mov	rsi, [r9]
		mov	[rdi + vsize], r8
.to_pop_end	pop	r9
		pop	r8
		ret


		;; Creates bInt from int
		;; TAKES:
		;;	RDI - integer - initial value of bInt
		;; RETURNS:
		;;	RAX - pointer to the created bInt
		;; USES:
		;;	R8 - pointer to the new bInt
		;;	R9 - initial value

biFromInt:	mov	r9, rdi
		mov	rdi, 1
		call	bInit
		mov	rdi, rax
		mov	rsi, r9
		call	bPush
		mov	rax, rdi
		ret

		;; void biAdd(BigInt dst, BigInt src)
		;; dst += scr
		;; TAKES:
		;;	RDI - dst
		;;	RSI - src
		;; USES:
		;;	
		;; RETURNS:
		;;	RDI - dst + src

biAddMod:	push	rbx
		push	r12
		push	r13
		xor	r13, r13
		push	rdi
		mov	rdi, 2
		call 	bInit
		pop	rdi
		mov	r9, [rdi + vsize]
		mov	r10, [rsi + vsize]
		cmp	r9, r10
		jle	.counting
		xchg	r9, r10
		xchg	rdi, rsi
		mov	r13, 1
.counting	mov	rcx, r9
		mov	r9, [rdi + start]
		mov	r10, [rsi + start]
		mov	r11, rdi
		mov 	r12, rsi
		mov	rdi, rax
		clc
		pushf
.loop		mov	rsi, [r9]
		popf
		adc	rsi, [r10]
		pushf
		call 	bPush
		add	r9, 8
		add	r10, 8
		dec	rcx
		jnz	.loop
		
		mov	rcx, [r12 + vsize]
		sub	rcx, [r11 + vsize]
		jz	.last_digit
.loop2		mov	rsi, [r10]
		popf	
		adc	rsi, 0
		pushf
		call	bPush
		add	r10, 8
		dec	rcx
		jnz	.loop2	

.last_digit	xor 	rsi, rsi
		popf
		adc	rsi, 0
		jz	.to_end
		call 	bPush
.to_end		xchg	rdi, r11
		mov	rsi, r12
		cmp	r13, 0
		je	.end
		xchg	rdi, rsi
.end		mov	rdi, r11
		push	r13
		push	r12
		pop	rbx
		ret

		;; void biToStringAsIs(BigInt src, char* buf)
		;; Outs bInt inner vector "as is". I used it for debugging
		;; TAKES:
		;;	RDI - source bInt
		;;	RSI - output buffer
		;; RETURNS:
		;;	RSI - output buffer with BigInt
biToStringAsIs:	push	rbx
		mov	rcx, [rdi + vsize]
		mov	r9, rsi
		mov	r10, [rdi + start]
		mov	r8, 10
.get_new	mov	rax, [r10]	
.div_loop	xor 	rdx, rdx
		div	r8
		add	rdx, '0'
		mov	[r9], dl
		inc	r9
		cmp	rax, 0
		jg	.div_loop
		add	r10, 8
		dec	rcx
		jnz	.get_new
		mov	byte [r9], 0
		pop	rbx
		ret		

;; %1 - where, %2 - how much, %3 - what TODO: fix this comment 
	%macro casn 3
		mov rdi, %1
		mov rcx, %2
		mov eax, %3
		cld
		rep stosd
	%endmacro
	

	
