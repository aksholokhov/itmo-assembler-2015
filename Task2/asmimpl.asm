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
	
matrixNew:	mov	r10, rdi
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
	;; Ask anton about push/pop r8 before this
		call	allign_alloc
		mov	[r8 + cells], rax
.cells_loop	mov 	[rax], 0
		dec	r10
		add	rax, 4
		cmp	r10, 0
		jg	.cells_loop
		mov	rax, r8
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
matrixClone:	mov r11, [rdi + cols]
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
	
matrixGet:	mov r12, rdi
		mov r11, [r12 + real_cols]
		imul r11, rsi
		lea r11, [r11 + rdx]
		mov r10, [r12 + cells]
		movss xmm0, [r10 + r11*4]
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

matrixSet:	mov r12, rdi
		mov r11, [r12 + real_cols]
	        imul r11, rsi
		lea r11, [r11 + rdx]
		mov r10, [r12 + cells]
		movss [r10 + r11*4], xmm0
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

matrixScale:	shufps xmm0, xmm0, 0
		call matrixClone
		mov r8, rax
		mov r10, [r8 + cells]
		mov r9, [r8 + real_rows]
		imul r9, [r8 + real_cols]
		shr r9, 2
		
.loop		movups, xmm1, xmm0
		
		