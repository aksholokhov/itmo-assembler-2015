 section .text


	extern malloc
	extern align_alloc
	extern free


	global matrixNew
	global matrixClone
	global matrixDelete
	global matrixGetRows
	global matrixGetCols
	global matrixGet
	global matrixSet
	global matrixScale
	global matrixAdd
	global matrixTranspose
	global matrixMul

		struc	Matrix
rows:		resq	1
cols:		resq	1
real_rows:	resq	1
real_cols:	resq	1
cells:		resq	1
		endstruc

	;;  Matrix matrixNew(unsigned int rows, unsigned int cols);
	;;
	;;  Takes:
	;;    RDI - unsigned int rows
	;;    RSI - unsigned int cols
	;;  Returns:
	;;    RAX - Matrix (=R8)
	;;  Uses:
	;;	R8 - Matrix
	;; 	R10 - temp variable for rows
	;; 	R11 - temp variable for cols

	;; Notes:
	;; 	For alignment by 4 it uses this formulae
	;;	R10 = ceil(rows / 4) * 4
	;;	R11 = ceil(cols / 4) * 4
	;; 	Alignment by 4 required for SSL using
	
matrixNew:	push	r8
		push	r10
		push	r11
		mov	r10, rdi
		mov	r11, rsi
		mov 	rdi Matrix_size
		call 	malloc
		mov 	r8, rax
		mov 	[r8 + rows], r10
		mov 	[r8 + cols], r11
	;; ceiling algorithm
		dec 	r10
		shr 	r10, 2
		shl 	r10, 2
		lea 	r10, [r10 + 4]
		mov 	[r8 + real_rows], r10
		dec 	r11
		shr 	r11, 2
		shl 	r11, 2
		lea 	r11, [r11 + 4]
		mov	[r8 + real_cols], r11
		imul	r10, r11
		lea	r10, [r10*4]
		mov	rdi, r10
		mov	rsi, 4
		call	allign_alloc
		mov	[r8 + cells], rax
.cells_loop	mov 	[rax], 0
		dec	r10
		add	rax, 4
		cmp	r10, 0
		jg	.cells_loop
		mov	rax, r8
		pop 	r11
		pop	r10
		pop	r8
		ret


	;;  void matrixDelete(Matrix matrix);
	;;
	;;  Takes:
	;;    RDI - Matrix matrix

matrixDelete:	mov r10, rdi
		mov rdi, [rdi + cells]
		call free
		mov rdi, r10
		call free
		ret

	;;  unsigned int matrixGetRows(Matrix matrix);
	;;
	;;  Takes:
	;;    RDI - Matrix matrix
	;;  Returns:
	;;    RAX - matrix.rows

matrixGetRows:	mov rax, [rdi + rows]
	        ret

	;;  unsigned int matrixGetCols(Matrix matrix);
	;;
	;;  Takes:
	;;    RDI - Matrix matrix
	;;  Returns:
	;;    RAX - matrix.cols

matrixGetCols:	mov rax, [rdi + cols]
	        ret


	;;  Matrix matrixClone(Matrix matrix);
	;;
	;;  Takes:
	;;    RDI - Matrix matrix
	;;  Returns:
	;;    RAX - new Matrix (=RDX)
	;;  Uses:
	;;    R8 - Matrix matrix (=RDI)
matrixCopy:	push r10
		push r12
		mov r11, [rdi + cols]
		mov r10, [rdi + rows]
		mov r12, rdi
		mov rdi, r10
		mov rsi, r11
		push r12
		call matrixNew
		pop r12
		mov rcx, [r12 + real_rows]
		imul rcx, [r12 + real_cols]
		mov rsi, [r8 + cells]
		mov rdi, [rax+ cells]
		cld
		rep movsd
		pop r12
		pop r10
		ret

	;;  float matrixGet(Matrix matrix, unsigned int row, unsigned int col);
	;;
	;;  Takes:
	;;    RDI - Matrix matrix
	;;    RSI - unsigned int row
	;;    RDX - unsigned int col
	;;  Returns:
	;;    XMM0 - matrix.cells[index]
	;;  Uses:
	;;    R8 - matrix.cells
	;;    R9 - index (=row * cols_align + col) 
	
matrixGet:	push r10
		push r11
		push r12
		mov r12, rdi
		mov r11, [r12 + real_cols]
		imul r11, rsi
		lea r11, [r11 + rdx]
		mov r10, [r12 + cells]
		movss xmm0, [r10 + r11*4]
		pop r12
		pop r11
		pop r10
		ret

	;;  void matrixSet(Matrix matrix, unsigned int row, unsigned int col, float valu\e)			;
	;;
	;;  Takes:
	;;    RDI - Matrix matrix
	;;    RSI - unsigned int row
	;;    RDX - unsigned int col
	;;    XMM0 - float value
	;;  Uses:
	;;    R8 - matrix.cells
	;;    R9 - index (=row * cols_align + col)

matrixSet:	push r10
		push r11
		push r12
		mov r12, rdi
		mov r11, [r12 + real_cols]
	        imul r11, rsi
		lea r11, [r11 + rdx]
		mov r10, [r12 + cells]
		movss [r10 + r11*4], xmm0
		pop r12
		pop r11
		pop r10
		ret

	;;  Matrix matrixScale(Matrix matrix, float k);
	;;
	;;  Takes:
	;;    RDI - Matrix matrix
	;;    XMM0 - float k
	;;  Returns:
	;;    RAX - new Matrix
	;;  Uses:
	;;    RCX - (matrix.rows_align * matrix.cols_align) / 4
	;;    RDX - new_matrix.cells

matrixScale:	push r8
		push r9
		push r10
		shufps xmm0, xmm0, 0
		call matrixCopy
		mov r8, rax
		mov r10, [r8 + cells]
		mov r9, [r8 + real_rows]
		imul r9, [r8 + real_cols]
		shr r9, 2
		
.loop		movups, xmm1, [r8]
		mulps xmm1, xmm0
		movups [r8], xmm1
		lea r8, [r8 + 16]
		dec r9
		jnz .loop
		mov rax, r8
		pop r10
		pop r9
		pop r8
		ret

	;;  Matrix matrixAdd(Matrix a, Matrix b);
	;;
	;;  Takes:
	;;    RDI - Matrix a
	;;    RSI - Matrix b
	;;  Returns:
	;;    RAX - new Matrix
	;;  Uses:
	;;    RCX - (new_matrix.rows_align * new_matrix.cols_align) / 4
	;;    RDX - new_matrix.cells
	;;    R8 - temporary register 1
	;;    R9 - temporary register 2
	
	 
	
matrixAdd:	push r8
		mov r8, [rdi + cols]
		cmp r8, [rsi + cols]
		jne .fail
		mov r8, [rdi + rows]
		cmp r8, [rsi + rows]
		jne .fail
		call matrixClone
		mov rcx, [rax + real_cols]
		imul rcx, [rax + real_rows]
		shr rcx, 2
		mov rdx, [rax + cells]
		mov rsi, [rsi + cells]
.loop		movups xmm0, [rdx]
		addps xmm0, [rsi]
		movups [rdx], xmm0
		lea rdx, [rdx + 16]
		lea rsi, [rsi + 16]
		dec rcx
		jnz .loop
		pop r8
		ret
.fail		xor rax, rax
		pop r8
		ret


	;;  Matrix matrixTranspose(Matrix matrix);
	;;
	;;  Takes:
	;;    RDI - Matrix matrix (m*n)
	;;  Returns:
	;;    RAX - matrix^T (n*m)
	;;  Uses:
	;;    R8 - m
	;;    R9 - n
	;;    R10 - mx_index
	;;    R11 - new_mx_index
	;;    RCX - i (0..m-1)
	;;    RDX - j (0..n-1)
	

matrixTranspose:
		push r8
		push r9
		push r10
		push r11
		mov r10, rdi
		mov rdi, [rdi + cols]
		mov rsi, [rdi + rows]
	        call matrixNew
	        mov rdi, r10
	        mov r8, [rax + real_cols]
	        mov r9, [rax + real_rows]
	        mov r10, [rdi + cells]
	        mov rdi, [rax + cells]
	        xor rcx, rcx
.loop_1:	xor rdx, rdx
	        lea r11, [rdi + rcx * 4]
.loop_2:	movups xmm0, [r10]
		mov r12, 3
.loop_3:	movss [r11], xmm0 
	        psrldq xmm0, 4
	        lea r11, [r11 + r8 * 4]
		dec r12
		cmp  r12, 0
		jg .loop3
	
        	movss [r11], xmm0
	        lea r11, [r11 + r8 * 4]

		lea rdx, [rdx + 4]
	        lea r10, [r10 + 16]
	        cmp rdx, r9
	        jb .loop_2
	        inc rcx
	        cmp rcx, r8
	        jb .loop_1
		pop r11
		pop r10
		pop r9
		pop r8
	        ret


	;;  Matrix matrixMul(Matrix a, Matrix b);
	;;
	;;  Takes:
	;;    RDI - Matrix a (m*n)
	;;    RSI - Matrix b (n*p)
	;;  Returns:
	;;    RAX - new Matrix (m*p)
	;;  Uses:
	;;    R8 - i (m-1..0)
	;;    R9 - j (p-1..0)
	;;    R10 - n
	;;    R11 - k (0..n-1)
	;;    RCX - new_mx_index
	;;    RBX - temporary variable 1
	;;    RBP - temporary variable 2
	;;    RDX - temporary variable 3

matrixMul:	mov r9, [rsi + rows]
	        cmp r8, [rsi + cols]
	        jne .fail

        	push rbx
	        push rbp
	        push rdi
	        push rsi
	        mov rdi, rsi
	        call matrixTranspose
	        pop rsi
	        pop rdi
	        push rax
	        push rdi
	
	        mov rdi, [rdi + rows]
	        mov rsi, [rsi + cols]
	        call matrixNew 
	        mov rcx, [rax + cells]
	        pop rdi
	        pop rsi
	        push rsi
	        mov r8, [rdi + real_rows]
	        mov r9, [rsi + real_rows]
	        mov r10, [rdi + real_cols]
	        mov rdi, [rdi + cells]
	        mov rsi, [rsi + cells]
	        mov rdx, rsi
	        mov rbx, r10
	        shl rbx, 2
	        mov rbp, r9
.loop_1:        mov rsi, rdx
	        mov r9, rbp
.loop_2:        xor r10, r10
	        xorps xmm0, xmm0
.loop_3:        movups xmm1, [rdi + r10] ; calculate dot product
	        movups xmm2, [rsi + r10]
	        dpps xmm1, xmm2, 0xF1
	        addss xmm0, xmm1
	        add r10, 16
	        cmp r10, rbx
	        jne .mul_loop_3
	        add rsi, rbx
	        movss [rcx], xmm0
	        add rcx, 4
	        dec r9
	        jnz .mul_loop_2
	        add rdi, rbx
	        dec r8
	        jnz .mul_loop_1
	        pop rdi
	        push rax
	        call matrixDelete ; deallocate b^T
	        pop rax
	        pop rbp
	        pop rbx
	        ret
.fail:          xor rax, rax
	        ret
	