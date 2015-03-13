global hw_sprintf

section .text

CONTROL_FLAG        equ  1              ;%  short name - C_flag
SIGN_FULL_FLAG      equ  1 << 1         ;+  short name - SF_flag
LEFT_ALIGN_FLAG     equ  1 << 2         ;-  short name - LA_flag
FILL_ZERO_FLAG      equ  1 << 3         ;0  short name - FZ_flag
ONLY_MINUS_FLAG     equ  1 << 4         ;   short name - OM_flag
LONG_FLAG           equ  1 << 5         ;ll short name - L_flag
SIGNED_NUM_FLAG     equ  1 << 6         ;id short name - SN_flag
REVERTED_SIGN_FLAG  equ  1 << 7         ;   short name - RS_flag


; SPRINTF FUNCTION
; edi - output stream address
; esi - format stream address
; ebp - current number address
; bh - flags
; bl - current character
; edx - width
; ecx - start of the control sequence

hw_sprintf:         push ebp
                    push esi
                    push edi
                    push ebx

                    xor ebx, ebx
                    xor edx, edx
                    xor ecx, ecx

                    mov edi, [esp + 20]     ; edi = out
                    mov esi, [esp + 24]     ; esi = format
                    lea ebp, [esp + 28]     ; ebp = nums

.char_matching      mov bl, byte [esi]      ; write the next format char to bl
                    cmp bl, '%'             ;
                    jne .read_control_seq
                    jmp .set_C_flag

.read_control_seq   cmp bl, '+'
                    je  .set_SF_flag
                    cmp bl, '-'
                    je  .set_LA_flag
                    cmp bl, ' '
                    je  .set_OM_flag
                    cmp bl, '0'
                    je  .set_FZ_flag
                    cmp bl, 'u'
                    je  .print_unsigned
                    cmp bl, 'i'
                    je  .print_signed
                    cmp bl, 'd'
                    je  .print_signed
                    cmp bl, 'l'
                    je  .try_set_L_flag
                    cmp bl, '0'
                    jg  .try_set_width
                    jmp .print_as_is

.next_char          cmp bl, 0
                    je  .after_all
                    inc esi
                    jmp .char_matching

.after_all          pop ebx
                    pop edi
                    pop esi
                    pop ebp
                    ret


;Flags setters
;set the value of the chosen flag and do related tasks

.set_C_flag         test bh, CONTROL_FLAG
                    jnz .print_as_is
                    or  bh, CONTROL_FLAG
                    mov ecx, esi             ;OR mov ecx, esi
                    jmp .read_control_seq

.set_SF_flag        or bh, SIGN_FULL_FLAG
                    jmp .next_char

.set_OM_flag        or bh, ONLY_MINUS_FLAG
                    jmp .next_char

.set_LA_flag        or bh, LEFT_ALIGN_FLAG
                    jmp .next_char

.set_FZ_flag        or bh, FILL_ZERO_FLAG
                    jmp .next_char

.try_set_L_flag     cmp [esi+1], bl
                    jne .next_char
                    or  bh, LONG_FLAG
                    jmp .next_char

.try_set_width      cmp bl, 9
                    jg  .print_as_is
                    jmp .read_int

;read functions
;reads the int from input buffer and stores it to edx
;input buffer address - esi
;output int - edx

.read_int           push ebx
                    xor eax, eax
.loop_read_int      mov ebx, 10
                    mul ebx
                    xor ebx, ebx
                    mov bl, byte [esi]
                    sub ebx, '0'
                    add eax, ebx
                    inc esi
                    cmp byte [esi], '9'
                    jg .after_read_int
                    cmp byte [esi], '1'
                    jge .loop_read_int
.after_read_int     mov edx, eax
                    pop ebx
                    jmp .char_matching


;Print functions

;prints numbers or sequences
.print_as_is        mov al, [ecx]
                    mov [edi], al
                    inc edi
                    inc ecx
                    cmp ecx, esi
                    jbe .print_as_is
                    xor al, al
                    xor ecx, ecx
                    xor bh, bh
                    jmp .next_char


.print_char         xor eax, eax
                    mov [edi], bl
                    inc edi
                    jmp .next_char


.print_signed        or bh, SIGNED_NUM_FLAG
                    jmp .print_signed

.print_unsigned      test bh, LONG_FLAG
                    jnz .print_int
                    jmp .print_long

.print_int          push edx                ;Width (stored in [esp+4]
                    push ebx                 ;Flags (stored in [esp]
                    mov ecx, [ebp]
                    test byte [esp], SIGNED_NUM_FLAG
                    jz  .stage1             ;Length calculating
                    cmp ecx, 0
                    jl  .revert_sign

;Calculates length of the number in [ebp] and stores result in ecx
.stage1             mov eax, [ebp]
                    xor ecx, ecx
                    mov edx, 10
.loop_stage1        div edx
                    inc ecx
                    cmp eax, 0
                    jg  .loop_stage1
                    push .stage2
                    jmp print_left_part
;module print
.stage2             add esp, 4
                    lea edi, [edi+ecx]
                    mov edx, [ebp]
                    mov eax, edx
                    mov ebx, 10
.loop_stage2        dec edi
                    mov dword [edi], 0
                    mov byte [edi], '0'
                    div ebx
                    mul ebx
                    sub edx, eax
                    add [edi], edx
                    div ebx
                    mov edx, eax
                    cmp edx, 0
                    jg .loop_stage2
                    lea edi, [edi+ecx]
                    push .stage3
                    test byte[esp+4], LEFT_ALIGN_FLAG
                    jnz print_right_part
                    add esp, 4
.stage3             add ebp, 4
                    pop ebx
                    pop edx
                    xor ebx, ebx
                    xor edx, edx
                    jmp hw_sprintf.next_char

;ecx - int, needs to be reverted
.revert_sign        or byte [esp], REVERTED_SIGN_FLAG
                    neg ecx
                    mov [ebp], ecx
                    ret

.print_long          ret

;prints sign, spaces or zeros before module.
print_left_part     add esp, 4
                    sub [esp+4], ecx
                    test byte [esp], REVERTED_SIGN_FLAG
                    jnz .reserve_sign_place
                    test byte [esp], SIGN_FULL_FLAG
                    jnz .reserve_sign_place
                    test byte [esp], ONLY_MINUS_FLAG
                    jnz .reserve_sign_place
.after_reservation  test byte [esp], LEFT_ALIGN_FLAG
                    jz .print_left_spaces
                    test byte [esp], FILL_ZERO_FLAG
                    jz .print_left_spaces
.print_sign         test byte [esp], REVERTED_SIGN_FLAG
                    jnz .print_minus
                    test byte [esp], SIGN_FULL_FLAG
                    jnz .print_plus
                    test byte [esp], ONLY_MINUS_FLAG
                    jnz .print_space
.try_print_zeroes   test byte [esp], LEFT_ALIGN_FLAG
                    jz  .print_zeroes
                    sub esp, 4
.to_ret             ret


;Helping functions for left part printing

.reserve_sign_place dec dword[esp+4]
                    jmp .after_reservation

; Prints spaces in amount of [esp+4]
.print_left_spaces  mov edx, [esp+4]
.print_ls_loop      cmp edx, 0
                    jle .print_ls_after
                    mov byte [edi], ' '
                    inc edi
                    dec edx
                    jmp .print_ls_loop
.print_ls_after     mov dword [esp+4], 0
                    jmp .print_sign

.print_plus         mov byte[edi], '+'
                    inc edi
                    jmp .try_print_zeroes

.print_minus        mov byte[edi], '-'
                    inc edi
                    jmp .try_print_zeroes

.print_space        mov byte[edi], ' '
                    inc edi
                    jmp .try_print_zeroes

;Prints zeroes in amount of [esp+4]
.print_zeroes       mov edx, [esp+4]
.print_zeroes_loop  cmp edx, 0
                    jle .print_z_after
                    mov byte [edi], '0'
                    inc edi
                    dec edx
                    jmp .print_zeroes_loop
.print_z_after      mov dword [esp+4], 0
                    jmp .to_ret

;Prints right part
print_right_part    mov edx, [esp+4]
.right_part_loop    cmp edx, 0
                    jle .right_part_loop
                    mov byte [edi], ' '
                    inc edi
                    dec edx
                    jmp hw_sprintf.stage3


; other functions
