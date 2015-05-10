section .text

	extern malloc
	extern free

	global biInit
	global biPop
	global biPush
	global biEnl
	global biToStringAsIs	;; outs inner array of bInt "as is" (for debugging) TODO: remove from global before submitting
	global biAddMod		;; |a| + |b|, TODO: remove from global before submitting
	global biSubMod
	global biFromInt
	global biFromString
	global biToString
	global biDelete
	global biSign
	global biAdd
	global biSub
	global biMul
	global biMulSc
	global biCmp
	global biCopy

TEN 	equ	10		;; It's ten, suddenly. 
BASE	equ 	100000000 	;; Base of the scale of notation
DIG_LEN	equ	8		;; Length of the one digit of number in chars

	struc	BigInt		;; BigInt struct
sign:	resq	1		;; sign of the BigInt
elem:	resq	1		;; elements of the inner vector
vsize:	resq	1		;; number of the elements of the inner vector
limit:	resq	1		;; size limit of the vector (the power of 2)
	endstruc


	;; Push all system necessary regs	
	%macro syspush 0
		push	rbx
		push	rbp
		push	r12
		push	r13
		push	r14
		push	r15
	%endmacro 

	;; Pop all system necessary regs
	%macro syspop 0
		pop	r15
		pop	r14
		pop	r13
		pop	r12
		pop	rbp
		pop	rbx
	%endmacro


	;; Malloc with stack aligning by 16
	;; TAKES:
	;;	RDI - size of the allocated memory
	;; RETURNS:
	;;	RAx - allocated memory address

alligned_malloc:
		test	rsp, 15
		jz	.malloc
		sub	rsp, 8
		call	malloc
		add	rsp, 8
		ret			
.malloc		call	malloc
		ret

	;; Free with stack aligning by 16
	;; TAKES:
	;;	RDI - address of the memory

alligned_free:
		test	rsp, 15
		jz	.free
		sub	rsp, 8
		call	free
		add	rsp, 8
		ret			
.free		call	free
		ret
	;; Initialises a BigInt with initial inner
	;; vector size of RDI
	;; TAKES:
	;;	RDI - initial vector size = 2^RDI
	;; USES:
	;;	RAX - address of allocated memory (bInt and vector)
	;;	RDI - size of allocated memory
	;; RETURNS:
	;;	RAX - new bInt
biInit:		syspush
		push	r8
		push	r9
		push	rsi
		push	rdx
		mov	r8, rdi
		mov	rdi, BigInt_size
		push	r8
		call 	alligned_malloc
		pop	r8
		mov	r9, 1
.loop		shl	r9, 1
		dec	r8
		jnz	.loop
		mov	qword [rax + sign], 0
		mov	qword [rax + vsize], 0
		mov	qword [rax + limit], r9
		mov	rdi, r9
		shl	rdi, 3
		mov	r9, rax
		push	r9
		call	alligned_malloc
		pop	r9
		mov	[r9 + elem], rax
		mov	r8, [r9 + limit]
.loop2		mov	qword[rax], 0
		add	rax, 8
		dec	r8
		jnz	.loop2
		mov	rax, r9	
		pop	rdx
		pop	rsi
		pop	r9
		pop	r8
		syspop
		ret

	;; void biDelete(BigInt a);
	;; Delete the BigInt a with his inner vector
	;; TAKES:
	;;	RDI - a
biDelete:	push	rdi
		mov	rdi, [rdi + elem]
		call	alligned_free
		pop	rdi
		call	alligned_free
		ret
	
	;; void biPush(BigInt a, int v)
	;; Add a new (oldest) digit in BigInt inner vector
	;; TAKES:
	;;	RDI - address of the bInt
;;	RSI - pushed value
	;; USES:
	;;	R8 - size
biPush:		push 	r8
		push	r9
		mov	r8, [rdi + vsize]
		mov	r9, [rdi + limit]
		cmp	r8, r9
		jl	.after
		;push	rdi
		call	biEnl
		;pop	rdi
.after		mov	r9, [rdi + elem]
		lea	r9, [r9 + r8 * 8]
		mov	[r9], rsi
		inc	r8
		mov	[rdi + vsize], r8
		pop	r9
		pop	r8
		ret

	;; void biEnl(BigInt a)
	;; Enlarges inner vector of bInt in 2 times
	;; TAKES
	;;	RDI - address of bInt
biEnl: 		syspush
		push	r8
		push	r9
		push	r10
		push	rax
		push	rsi
		push	rdx
		push	rcx

		mov	rsi, rdi
		mov	rdi, [rsi + limit]
		shl	rdi, 4
		push	rsi
		push	rdi
		call	alligned_malloc
		pop	rdi
		pop	rsi
		shr	rdi, 3
		mov	[rsi + limit], rdi
		mov	r8, [rsi + elem]
		mov	r10, [rsi + vsize]	
		mov	r9, rax
.enl_loop	mov	rdi, [r8]
		mov	[r9], rdi
		add	r8, 8
		add	r9, 8
		dec	r10
		jnz	.enl_loop
		mov	rdi, [rsi + elem]
		mov	[rsi + elem], rax
		push	rsi
		call	free
		pop	rsi
		mov	rdi, rsi
		
		pop	rcx
		pop	rdx
		pop	rsi	
		pop	rax
		pop	r10
		pop	r9
		pop	r8
		syspop	
		ret

		;; int biPop(BigInt a)
		;; makes "pop" from the inner BigInt vector to the V
		;; TAKES:
		;;	rdi - bInt
		;; RETURNS:
		;;	rax - v with the head of the vector if it's size > 0 or 0 if not
biPop 		mov	r8, [rdi + vsize]
		cmp	r8, 0
		jne	.to_pop
		mov	rax, -1
		jmp	.to_pop_end
.to_pop		dec	r8
		mov	r9, [rdi + elem]
		lea	r9, [r9 + r8 * 8]
		mov	rax, [r9]
		mov	[rdi + vsize], r8
.to_pop_end	ret


		;; int biHead(BigInt a)
		;; returns a head of the inner vector
		;; TAKES:
		;;	RDI - BigInt a
		;; RETURNS:
		;;	RAX - the value in the head of the vector
		;; USES:
		;;	R8 - pointer to the elements
		;;	R9 - size of the vector
biHead		mov	r8, [rdi + elem]
		mov	r9, [rdi + vsize]
		dec	r9
		lea	r8, [r8 + r9 * 8]
		mov	rax, [r8]
		ret

		;; Creates bInt from int
		;; TAKES:
		;;	RDI - integer - initial value of bInt
		;; RETURNS:
		;;	RAX - poiner to the created bInt
		;; USES:
		;;	R8 - pointer to the new bInt
		;;	R9 - initial value

biFromInt:	mov	r9, rdi
		mov	rdi, 1
		call	biInit
		mov	rdi, rax
		mov	rsi, r9
		call	biPush
		mov	rax, rdi
		ret

		;; BigInt biFromString(char const* s);
		;; Creates BigInt from the given string
		;; TAKES:
		;;	RDI - string
		;; RETURNS:
		;;	RAX - created BigInt

biFromString:	syspush
		push	rdx
		push	rcx
		push	r8
		push	r9
		push	r10

		mov	rdx, rdi
		mov	rdi, 1		; let initial length limit of the big int be 2 digits (2^rdi)
		call	biInit		; Create new empty BigInt
		cmp	byte[rdx], '-'	; if first sign isn't '-'
		jne	.not_minus	; skip the change of the sign	
		mov	qword[rax + sign], 1	; else change it
		inc	rdx		; and go to the next character

.not_minus	xor	rcx, rcx	; clear the counter 
.correct_check	cmp	byte[rdx], '9'	; If the character is bigger than 9
		jg	.fail		; and less than 0, it's not a digit, 
		cmp	byte[rdx], '0'	; so we have incorrect string and
		jl	.fail		; go to the .fail block.
		inc	rdx		; After this cycle we'll have the smallest digit of the number in rdx
		inc	rcx		; and the length of the number in rcx
		cmp	byte[rdx], 0
		jne	.correct_check
		cmp	rcx, 0
		je	.fail		; if the size is 0 it's incorrect string
		dec	rdx		; String pointer to the last symbol
		
		mov	rbp, rdx	; Save pointer to rbp
		mov	rdi, rax	; BigInt to rdi: first arg for biPush
		mov	r8, TEN		
.loop_by_8	mov	r10, 1		; Multiplier-accumulator
		xor	rsi, rsi	; New number for vector: second arg 
		xor	rax, rax	; clear for mul op-s
		mov	r9, DIG_LEN	
		cmp	rcx, DIG_LEN	
		jge	.loop_by_1
		mov	r9, rcx		
.loop_by_1	mov	al, byte[rbp]
		sub	al, '0'
		mul	r10
		add	rsi, rax
		mov	rax, r10
		mul	r8
		mov	r10, rax
		xor	rax, rax
		xor	rdx, rdx
		dec	rbp
		dec	rcx
		dec	r9
		jnz	.loop_by_1
		push	rcx
		call	biPush		; TODO: potentially bugs
		pop	rcx	
.after_push	cmp	rcx, 0
		jg	.loop_by_8
		
.clr_zeroes	call 	biHead
		cmp	rax, 0
		jne	.to_zero_sign
		call	biPop
		jmp	.clr_zeroes	
		
.to_zero_sign	cmp	qword[rdi + vsize], 0
		jne	.to_ret
		mov	qword[rdi + sign], 0

.to_ret		mov	rax, rdi
		pop	r10
		pop	r9
		pop	r8
		pop	rcx
		pop	rdx
		syspop
		ret

.fail		mov 	rax, 0
		pop	r10
		pop	r9
		pop	r8
		pop	rcx
		pop	rdx
		syspop
		ret
					

		;; void biAddMod(BigInt dst, BigInt src)
		;; dst += scr as modulo 
		;; TAKES:
		;;	RDI - dst
		;;	RSI - src
		;; USES:
		;;	
		;; RETURNS:
		;;	RDI - dst + src

biAddMod:	syspush
		push	rdi
		push	rsi
		mov	rdi, 2
		call 	biInit
		pop	rsi
		pop	rdi
		xor	r13, r13 	;clear "swap RDI RSI"	flag
		mov	r9, [rdi + vsize]
		mov	r10, [rsi + vsize]
		cmp	r9, r10
		jle	.counting
		xchg	r9, r10
		xchg	rdi, rsi
		mov	r13, 1
.counting	mov	rcx, r9
		mov	r9, [rdi + elem]
		mov	r10, [rsi + elem]
		mov	r11, rdi
		mov 	r12, rsi
		mov	rdi, rax
		mov	r14, BASE
		xor	rax, rax
		xor	rdx, rdx
.loop		add	rax, [r9]
		add	rax, [r10]
		div	r14		
		mov	rsi, rdx
		call 	biPush
		xor 	rdx, rdx
		add	r9, 8
		add	r10, 8
		dec	rcx
		jnz	.loop
		
		mov	rcx, [r12 + vsize]
		sub	rcx, [r11 + vsize]
		jz	.last_digit

.loop2		add	rax, [r10]
		div	r14
		mov	rsi, rdx
		call	biPush
		xor	rdx, rdx
		add	r10, 8
		dec	rcx
		jnz	.loop2	

.last_digit	cmp	rax, 0
		je	.to_end
		mov	rsi, rax
		call 	biPush

.to_end		cmp	r13, 0
		je	.end
		xchg	r11, r12
.end		mov	rsi, rdi
		mov	rdi, r11
		push	r12
		call    biCopy
		pop	rsi
		syspop
		ret



		;; void biSubMod(BigInt dst, BigInt src)
		;; dst -= scr as modulo 
		;; TAKES:
		;;	RDI - dst (must be bigger than src or equal)
		;;	RSI - src
		;; USES:
		;;	
		;; RETURNS:
		;;	RDI - dst - src

biSubMod:	syspush
		mov	rcx, [rsi + vsize]
		mov	r9, [rdi + elem]
		mov	r10, [rsi + elem]
		xor	rax, rax
		xor	rdx, rdx

.loop		add	rax, [r9]
		sub	rax, [r10]
		jns	.ins_plus		
		add	rax, BASE
		mov	[r9], rax
		mov	rax, -1
		add	r9, 8
		add	r10, 8
		dec	rcx
		jnz	.loop
		jmp	.to_loop2		
.ins_plus	mov	[r9], rax
		xor	rax, rax
		add	r9, 8
		add	r10, 8
		dec	rcx
		jnz	.loop
		
.to_loop2	mov	rcx, [rdi + vsize]
		sub	rcx, [rsi + vsize]
		jz	.to_end

.loop2		add	rax, [r9]
		jns	.ins_plus2
		add	rax, BASE
		mov	[r9], rax
		mov	rax, -1
		add	r9, 8
		dec	rcx		
		jmp	.loop2		
.ins_plus2	mov	[r9], rax
		xor	rax, rax
		add	r9, 8
		dec	rcx
		jnz	.loop2		

.to_end		sub	r9, 8
		cmp	qword[r9], 0
		jne	.end
		call	biPop
.end		syspop
		ret

		;; void biAdd(BigInt a, BigInt b);
		;; a += b (according to the sign);
		;; TAKES:
		;;	RDI - BigInt a
		;;	RSI - BigInt b
		;; RETURNS:
		;;
biAdd:		mov	rax, [rdi + sign]
		cmp	rax, qword[rsi + sign]
		jne 	.sub
		push 	rax
		call	biAddMod
		pop	rax
		mov	[rdi + sign], rax
		ret
.sub		call	biCmpMod
		cmp	rax, 0
		jl	.sub_rev
		call 	biSubMod
		ret

.sub_rev	push	rdi
		push	rsi
		mov	rdi, 2
		call	biInit
		pop	rsi
		mov	rdi, rax
		call	biCopy
		pop	rsi
		call	biSubMod
		mov	rcx, [rsi + elem]
		mov	rax, [rdi + elem]
		mov	[rsi + elem], rax
		mov	rax, [rdi + limit]
		mov	[rsi + limit], rax
		mov	rax, [rdi + vsize]
		mov	[rsi + vsize], rax
		mov	rax, [rdi + sign]
		mov	[rsi + sign], rax
		mov	rdi, rcx
		call	alligned_free
		ret

		;; Copy BigInt b to BigInt a
		;; TAKES:
		;;	RDI - BigInt a
		;;	RSI - BigInt b
		;; RETURNS:
		;;	
biCopy		push	rdi
		push	rsi
		mov	rdi, [rsi + limit]
		shl	rdi, 3
		call	alligned_malloc
		pop	rsi
		pop	rdi
		mov	rdx, rax
		push	rdx
		push	rsi
		push	rdi
		mov	rdi, [rdi + elem]
		call 	alligned_free
		pop	rdi
		pop	rsi
		pop	rdx
		mov	rax, [rsi + vsize]
		mov	[rdi + vsize], rax
		mov	rax, [rsi + limit]
		mov	[rdi + limit], rax
		mov	rax, [rsi + sign]
		mov	[rdi + sign], rax
		mov	r8, rdx
		mov	r9, [rsi + elem]
		mov	rcx, [rsi + vsize]
.loop		mov	rax, [r9]
		mov	[r8], rax
		add	r9, 8
		add	r8, 8
		dec	rcx
		jnz	.loop
		mov	[rdi + elem], rdx
		ret
		

		;; void biMulSc(BigInt a, int k, int shift)
		;; Muls a to k
		;; TAKES:
		;;	RDI - BigInt a
		;;	RSI - int k; 0 < k < BASE
		;;	RDX - int shift; < a.size
		;; RETURNS:
		;;	
biMulSc:	syspush
		mov	rcx, [rdi + vsize]
		sub	rcx, rdx
		mov	r8, [rdi + elem]
		lea	r8, [r8 + rdx * 8]
		mov	r9, BASE
		xor	rax, rax
		xor	rdx, rdx
		xor	rbx, rbx

.loop		mov	rax, [r8]
		mul	rsi
		add	rax, rbx
		div	r9
		mov	[r8], rdx 
		mov	rbx, rax
		xor	rdx, rdx
		add	r8, 8
		dec	rcx
		jnz	.loop
		
		cmp	rbx, 0
		je	.to_end	
		mov	rsi, rbx
		call	biPush
.to_end		syspop
		ret

		;; void BiMul(BigInt a, BigInt b);
		;; TAKES:
		;;	RDI - BigInt a
		;;	RSI - BigInt b
		;; RETURNS:
		;;	
biMul:		syspush
		mov	rax, [rdi + vsize]
		add	rax, [rsi + vsize]
		push	rax
		xor	rcx, rcx
.lencount	inc	rcx
		shr	rax, 1
		jnz	.lencount
		inc	rcx
		
		push	rsi
		push	rdi
		mov	rdi, rcx
		call	biInit
		pop	rdi
		pop	rsi
		mov	r10, rax		
		pop	rax
		mov	[r10 + vsize], rax		

		xor 	rax, rax
		xor	rdx, rdx
		mov	r8, [rdi + elem]
		mov	r13, BASE
		mov	r11, 0	
.loop1		mov	r12, 0
		mov	r9, [rsi + elem]
		xor	rcx, rcx
.loop2		mov	rax, [r8]
		mul	qword[r9]
		add	rax, rcx
		mov	rbx, [r10 + elem]
		lea	rbx, [rbx + r11 * 8]
		lea	rbx, [rbx + r12 * 8]
		add	rax, [rbx]
		div	r13
		mov	rcx, rax
		mov	[rbx], rdx
		xor	rdx, rdx
		inc	r12
		add	r9, 8
		cmp	r12, [rsi + vsize]
		jl	.loop2
		mov	rbx, [r10 + elem]
		lea	rbx, [rbx + r11*8]
		mov	rdx, [rsi + vsize]
		lea	rbx, [rbx + rdx*8]
		mov	[rbx], rcx
		inc	r11
		add	r8, 8
		cmp	r11, [rdi + vsize]
		jl	.loop1
		push	rdi
		push	rsi
		mov	rdi, r10		
.clr_zeroes	call	biHead
		cmp	rax, 0
		jne	.to_sign
		call	biPop
		jmp	.clr_zeroes		
.to_sign	pop	rax
		pop	rcx
		mov	rax, [rax + sign]
		xor	rax, [rcx + sign]
		mov	[rdi + sign], rax
		mov	rsi, rdi
		mov	rdi, rcx
		push	rsi
		call	biCopy
		pop	rdi
		call	biDelete
		syspop	
		ret


		;; void biToStringAsIs(BigInt src, char* buf)
		;; Outs bInt inner vector "as is". I used it for debugging
		;; TAKES:
		;;	RDI - source bInt
		;;	RSI - output buffer
		;;	RDX - limit
		;; RETURNS:
		;;	RSI - output buffer with BigInt
biToString:	syspush
		push	rdi
		push 	rsi
		push	rdx
		mov	rdi, [rdi + vsize]
		inc	rdi
		shl	rdi, 3
		call	alligned_malloc
		pop	rdx
		pop	rsi
		pop	rdi
		mov	r11, rax
		push	rsi
		push	rax
		push 	rdx
		mov	rcx, [rdi + vsize]
		mov	r10, [rdi + elem]
		
.to_module	mov	r8, 10
		xor	rbx, rbx
.get_new	mov	rax, [r10]	
		cmp	rax, 0
		je	.maybe_mid_0
.div_loop	xor 	rdx, rdx
		div	r8
		add	rdx, '0'
		mov	[r11], dl
		inc	r11
		inc	rbx
		cmp	rax, 0
		jg	.div_loop
.after_div	mov	byte[r11], ' '
		inc	r11
		inc	rbx
		add	r10, 8
		dec	rcx
		cmp	rcx, 0
		jg	.get_new

		cmp	qword[rdi + sign], 1
		jne	.to_rev_out	
		mov	byte [r11], '-'
		inc	r11
		inc	rbx		
		
.to_rev_out	dec	r11
		pop	rdx
		cmp	rbx, rdx
		jle	.reverse_loop
		xchg	rbx, rdx
		
.reverse_loop	mov	al, byte[r11]
		mov	[rsi], al
		dec	r11
		inc	rsi
		dec	rbx
		jnz	.reverse_loop
		mov	byte[rsi], 0
		pop	rdi
		call 	alligned_free
		pop	rsi
		mov	al, byte[rsi]
		syspop	
		ret		

.maybe_mid_0	cmp	qword[rdi + vsize], 0
		je	.div_loop
		mov	rax, DIG_LEN
.loop_mid_0	mov	byte[r11], '0'
		inc	r11
		inc	rbx
		dec	rax
		jnz	.loop_mid_0
		jmp	.after_div


		;; Returns sign of the BigInt
		;; TAKES:
		;;	RDI - BigInt a
		;; RETURNS:
		;;	RAX - 1 if a > 0; 0 if a == 0; else -1
biSign:		mov	rax, [rdi + sign]
		cmp	rax, 0
		jg	.to_minus
		mov	r8, [rdi + elem]
		mov	r9, [rdi + vsize]
.loop		mov	rdx, [r8]
		cmp	rdx, 0
		jg	.to_plus
		add	r8, 8
		dec	r9
		cmp	r9, 0
		jg	.loop
		mov	rax, 0
		jmp	.to_ret
.to_plus	mov	rax, 1
		jmp	.to_ret
.to_minus	mov	rax, -1
.to_ret		ret


		;; Compares two BigInts
		;; TAKES:
		;;	RDI - BigInt a
		;;	RSI - BigInt b
		;; RETURNS:
		;;	RAX - 0 if a == b; 1 if a > b; else -1
biCmp:		mov	r8, [rdi + sign]
		mov	r9, [rsi + sign]
		cmp	r8, r9
		jg	.smaller
		jl	.bigger
		mov	r8, [rdi + vsize]
		mov	r9, [rsi + vsize]
		cmp	r8, r9
		jg	.bigger
		jl	.smaller
		mov	r8, [rdi + elem]
		mov	r9, [rsi + elem]
		mov	rcx, [rdi + vsize]
.loop		mov	rax, [r8]
		cmp	rax, qword[r9]
		jg	.bigger
		jl	.smaller
		add	r8, 8
		add	r9, 8
		dec	rcx
		cmp	rcx, 0
		jg 	.loop
		mov	rax, 0
		jmp	.to_ret
.bigger		mov	rax, 1
		jmp	.to_ret
.smaller	mov	rax, -1
.to_ret		ret

		;; Compares two BigInts modulo two
		;; TAKES:
		;;	RDI - BigInt a
		;;	RSI - BigInt b
		;; RETURNS:
		;;	RAX - 0 if a == b; 1 if a > b; else -1

biCmpMod:	mov	r8, [rdi + vsize]
		mov	r9, [rsi + vsize]
		cmp	r8, r9
		jg	.bigger
		jl	.smaller
		mov	r8, [rdi + elem]
		mov	r9, [rsi + elem]
		mov	rcx, [rdi + vsize]
.loop		mov	rax, [r8]
		cmp	rax, qword[r9]
		jg	.bigger
		jl	.smaller
		add	r8, 8
		add	r9, 8
		dec	rcx
		cmp	rcx, 0
		jg 	.loop
		mov	rax, 0
		jmp	.to_ret
.bigger		mov	rax, 1
		jmp	.to_ret
.smaller	mov	rax, -1
.to_ret		ret

;; %1 - where, %2 - how much, %3 - what TODO: fix this comment 
	%macro casn 3
		mov rdi, %1
		mov rcx, %2
		mov eax, %3
		cld
		rep stosd
	%endmacro
	

	
